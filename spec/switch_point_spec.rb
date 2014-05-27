RSpec.describe SwitchPoint do
  describe '.writable!' do
    after do
      SwitchPoint.readonly!(:main)
    end

    it 'changes connection globally' do
      expect(Book).to connect_to('main_readonly.sqlite3')
      expect(Publisher).to connect_to('main_readonly.sqlite3')
      SwitchPoint.writable!(:main)
      expect(Book).to connect_to('main_writable.sqlite3')
      expect(Publisher).to connect_to('main_writable.sqlite3')
    end
  end
end
