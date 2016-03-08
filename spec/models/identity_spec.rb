RSpec.describe Identity, type: :model do
    it { should belong_to :user }
    it { should validate_presence_of :provider }
    it { should validate_presence_of :uid }
    it { should validate_presence_of :user_id }
end
