class Chess::SurrenderController < ApplicationController
    before_action :authenticate_user!
    
    def index
        game = Game.find(params[:id])
        game.complete(current_user.id == game.user_id ? 0 : 1) if !game.nil? && game.is_player?(current_user.id)
        render nothing: true
    end
end