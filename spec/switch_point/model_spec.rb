RSpec.describe SwitchPoint::Model do
  describe '.connection' do
    it 'returns readonly connection by default' do
      expect(Book).to connect_to('main_readonly.sqlite3')
      expect(Publisher).to connect_to('main_readonly.sqlite3')
      expect(User).to connect_to('user.sqlite3')
      expect(Comment).to connect_to('comment_readonly.sqlite3')
      expect(Note).to connect_to('default.sqlite3')
    end

    context 'without switch_point configuration' do
      it 'returns default connection' do
        expect(Note.connection).to equal(ActiveRecord::Base.connection)
      end
    end

    context 'with the same switch point name' do
      it 'shares connection' do
        expect(Book.connection).to equal(Publisher.connection)
      end
    end
  end

  describe '.with_writable' do
    it 'changes connection locally' do
      Book.with_writable do
        expect(Book).to connect_to('main_writable.sqlite3')
      end
      expect(Book).to connect_to('main_readonly.sqlite3')
    end

    it 'affects to other models with the same switch point' do
      Book.with_writable do
        expect(Publisher).to connect_to('main_writable.sqlite3')
      end
      expect(Publisher).to connect_to('main_readonly.sqlite3')
    end

    it 'does not affect to other models with different switch point' do
      Book.with_writable do
        expect(Comment).to connect_to('comment_readonly.sqlite3')
      end
    end

    context 'with the same switch point' do
      it 'shares connection' do
        Book.with_writable do
          expect(Book.connection).to equal(Publisher.connection)
        end
      end
    end
  end

  describe '.with_readonly' do
    context 'when writable! is called globally' do
      before do
        SwitchPoint.writable!(:main)
      end

      after do
        SwitchPoint.readonly!(:main)
      end

      it 'locally overwrites global mode' do
        Book.with_readonly do
          expect(Book).to connect_to('main_readonly.sqlite3')
        end
        expect(Book).to connect_to('main_writable.sqlite3')
      end
    end
  end
end
