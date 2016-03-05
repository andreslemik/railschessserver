class Game < ActiveRecord::Base
    belongs_to :user
    belongs_to :opponent, class_name: 'User', foreign_key: 'opponent_id'

    has_one :board
    has_many :turns

    validates :user_id, :opponent_id, presence: true

    scope :accessable, -> { where(access: true) }
    scope :current, -> { where(game_result: nil) }
    scope :finished, -> { where.not(game_result: nil) }

    after_create :board_build

    def self.build(user_1, user_2, access)
        game = create user_id: user_1, opponent_id: user_2, access: access
    end

    def check_users_turn(user_id)
        result = user_id == self.user_id && self.white_turn || user_id == self.opponent_id && !self.white_turn ? nil : 'Сейчас не ваш черед ходить'
    end

    def check_cells(from, to)
        result = from == to ? 'Должны быть указаны разные ячейки' : nil
        return result unless result.nil?
        errors = 0
        [from, to].each { |index| errors += 1 if index.size > 2 || %w(a b c d e f g h).index(index[0]).nil? || %w(1 2 3 4 5 6 7 8).index(index[1]).nil? }
        result = errors > 0 ? 'Указана неправильная ячейка' : nil
    end

    def check_right_figure(from)
        figure = self.board.cells.find_by(x_param: from[0], y_param: from[1]).figure
        result = figure.nil? ? "В клетке '#{from}' нет фигуры для хода" : nil
        return result unless result.nil?
        f_color = figure.color
        result = f_color == 'white' && self.white_turn || f_color == 'black' && !self.white_turn ? nil : 'Нельзя ходить чужой фигурой'
    end

    def check_turn(from, to)
        cells_list = self.board.cells
        figure = cells_list.find_by(name: from).figure
        finish_cell = cells_list.find_by(name: to).figure
        x_params, y_params = %w(a b c d e f g h), %w(1 2 3 4 5 6 7 8)
        x_change = x_params.index(to[0]) - x_params.index(from[0])
        y_change = y_params.index(to[1]) - y_params.index(from[1])
        p_pass, roque = nil, nil
        case figure.type
            when 'k'
                result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход королем'
                if result.nil?
                    protectes = figure.color == 'white' ? figure.board.game.black_protectes : figure.board.game.white_protectes
                    result = protectes.include?(to) ? 'Нельзя атаковать, фигура защищена' : nil
                end
                if !result.nil? && x_change.abs == 2 && y_change == 0
                    if figure.color == 'white'
                        k_place = 'e1'
                        r_place = x_change > 0 ? 'h1' : 'a1'
                    else
                        k_place = 'e8'
                        r_place = x_change > 0 ? 'h8' : 'a8'
                    end
                    did_k_turn = self.turns.where(from: k_place).any?
                    did_r_turn = self.turns.where(from: r_place).any?
                    roque_figure = cells_list.find_by(name: r_place).figure
                    result = roque_figure.nil? ? 'Нет ладьи для рокировки' : nil
                    result = result.nil? && did_k_turn && did_r_turn ? 'Нельзя рокироваться, фигуры двигались' : nil
                    roque = roque_figure if result.nil?
                end
            when 'q' then result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход ферзём'
            when 'r' then result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход ладьёй'
            when 'n' then result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход конём'
            when 'b' then result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход слоном'
            when 'p'
                protectors = figure.color == 'white' ? self.w_king_protectors : self.b_king_protectors
                if protectors.include?(figure.cell.name) && x_change == 0 && y_change.abs > 0
                    result = 'Эта пешка защищает короля'
                else
                    near_x_param = x_params[x_params.index(from[0]) + x_change]
                    near_figure = cells_list.find_by(x_param: near_x_param, y_param: from[1]).figure
                    if near_figure && near_figure.type == 'p' && near_figure.color != figure.color
                        last_turn = self.turns.last
                        p_pass = near_figure if last_turn.to == "#{near_x_param}#{from[1]}" && last_turn.from == "#{near_x_param}#{from[1].to_i + y_change * 2}"
                    end
                    result = figure.color == 'white' && (x_change == 0 && y_change == 1 && finish_cell.nil? || x_change == 0 && y_change == 2 && from[1] == '2' && finish_cell.nil? || figure.beaten_fields.include?(to) && !finish_cell.nil? && finish_cell.color == 'black' || figure.beaten_fields.include?(to) && !p_pass.nil?) || figure.color == 'black' && (x_change == 0 && y_change == -1 && finish_cell.nil? || x_change == 0 && y_change == -2 && from[1] == '7' && finish_cell.nil? || figure.beaten_fields.include?(to) && !finish_cell.nil? && finish_cell.color == 'white' || figure.beaten_fields.include?(to) && !p_pass.nil?) ? nil : 'Неправильный ход пешкой'
                end
        end
        return result unless result.nil?
        if figure.type == 'k' && !roque.nil? && x_change.abs > 1 && y_change == 0
            line = roque.cell.y_param
            checks = roque.cell.x_param == 'a' ? ["b#{line}", "c#{line}", "d#{line}"] : ["f#{line}", "g#{line}"]
            check_beated = roque.cell.x_param == 'a' ? ["c#{line}", "d#{line}", "e#{line}"] : ["e#{line}", "f#{line}"]
            checks.each do |box|
                check = cells_list.find_by(name: box).figure
                result = check.nil? ? nil : 'На пути рокировки есть препятствие'
                break unless result.nil?
            end
            if result.nil?
                check_beated.each do |box|
                    self.board.figures.on_the_board.where('color != ?', figure.color).each do |figure|
                        result = figure.beaten_fields.include?(box) ? 'Рокировка под ударом' : nil
                        break unless result.nil?
                    end
                    break unless result.nil?
                end
            end
        end
        return result unless result.nil?
        if !p_pass.nil?
            result = ["#{p_pass.cell.x_param}#{p_pass.cell.y_param}", '0']
        elsif !roque.nil?
            another = roque.cell.x_param == 'a' ? 'd' : 'f'
            result = ["#{roque.cell.x_param}#{roque.cell.y_param}", "#{another}#{roque.cell.y_param}"]
        elsif figure.type == 'p' && to[1] == '1' || to[1] == '8'
            result = ['0', "#{figure.color}"]
        end
        result
    end

    def checkmat_check
        if self.white_turn
            self.blacks_check
            self.whites_check
        else
            self.whites_check
            self.blacks_check
        end
    end

    def whites_check
        if self.white_beats.include?(self.board.figures.find_by(type: 'k', color: 'black').cell.name)
            case self.white_checkmat
                when nil then self.update(white_checkmat: 'check')
                when 'check' then self.complete(1)
            end
        end
    end

    def blacks_check
        if self.black_beats.include?(self.board.figures.find_by(type: 'k', color: 'white').cell.name)
            case self.black_checkmat
                when nil then self.update(black_checkmat: 'check')
                when 'check' then self.complete(0)
            end
        end
    end

    def complete(game_result)
        case game_result
            when 1 then self.update(white_checkmat: 'mat', game_result: 1, game_result_text: 'Победа белых')
            when 0 then self.update(black_checkmat: 'mat', game_result: 0, game_result_text: 'Победа чёрных')
        end
        user, opponent = self.user, self.opponent
        ra, rb = user.elo, opponent.elo
        sa, sb = game_result, 1 - game_result
        ea, eb = (1 / (1 + 10 ** ((rb - ra) / 400.0))).round(4), (1 / (1 + 10 ** ((ra - rb) / 400.0))).round(4)
        output = []
        [[ra, ea, sa], [rb, eb, sb]].each do |r|
            if r[0] >= 2400
                k = 10
            elsif r[0] < 2400 && r[0] >= 2300
                k = 20
            else
                k = 40
            end
            output.push(r[0] + k * (r[2] - r[1]))
        end
        user.update(elo: output[0])
        opponent.update(elo: output[1])
    end

    private
    def board_build
        Board.build(self)
    end
end
