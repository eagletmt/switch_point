RSpec.describe SwitchPoint do
  describe '.writable_all!' do
    after do
      SwitchPoint.readonly_all!
    end

    it 'changes connection globally' do
      expect(Book).to connect_to('main_readonly.sqlite3')
      expect(Book3).to connect_to('main2_readonly.sqlite3')
      expect(Comment).to connect_to('comment_readonly.sqlite3')
      expect(User).to connect_to('user.sqlite3')
      expect(BigData).to connect_to('main_readonly_special.sqlite3')
      SwitchPoint.writable_all!
      expect(Book).to connect_to('main_writable.sqlite3')
      expect(Book3).to connect_to('main2_writable.sqlite3')
      expect(Comment).to connect_to('comment_writable.sqlite3')
      expect(User).to connect_to('user.sqlite3')
      expect(BigData).to connect_to('main_writable.sqlite3')
    end

    it 'affects thread-globally' do
      SwitchPoint.writable_all!
      Thread.start do
        expect(Book).to connect_to('main_writable.sqlite3')
        expect(Book3).to connect_to('main2_writable.sqlite3')
        expect(Comment).to connect_to('comment_writable.sqlite3')
        expect(User).to connect_to('user.sqlite3')
        expect(BigData).to connect_to('main_writable.sqlite3')
      end.join
    end

    context 'within with block' do
      it 'changes the current mode' do
        SwitchPoint.writable_all!
        Book.with_readonly do
          expect(Book).to connect_to('main_readonly.sqlite3')
        end
        expect(Book).to connect_to('main_writable.sqlite3')
        Book.with_writable do
          expect(Book).to connect_to('main_writable.sqlite3')
        end
      end
    end
  end

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

    it 'affects thread-globally' do
      SwitchPoint.writable!(:main)
      Thread.start do
        expect(Book).to connect_to('main_writable.sqlite3')
      end.join
    end

    context 'within with block' do
      it 'changes the current mode' do
        Book.with_writable do
          SwitchPoint.readonly!(:main)
          expect(Book).to connect_to('main_readonly.sqlite3')
        end
        expect(Book).to connect_to('main_readonly.sqlite3')
        Book.with_writable do
          expect(Book).to connect_to('main_writable.sqlite3')
        end
      end
    end

    context 'with unknown name' do
      it 'raises error' do
        expect { SwitchPoint.writable!(:unknown) }.to raise_error(KeyError)
      end
    end
  end

  describe '.with_writable' do
    it 'changes connection' do
      SwitchPoint.with_writable(:main, :nanika1) do
        expect(Book).to connect_to('main_writable.sqlite3')
        expect(Publisher).to connect_to('main_writable.sqlite3')
        expect(Nanika1).to connect_to('default.sqlite3')
      end
      expect(Book).to connect_to('main_readonly.sqlite3')
      expect(Publisher).to connect_to('main_readonly.sqlite3')
      expect(Nanika1).to connect_to('main_readonly.sqlite3')
    end

    context 'with unknown name' do
      it 'raises error' do
        expect { SwitchPoint.with_writable(:unknown) { raise RuntimeError } }.to raise_error(KeyError)
      end
    end
  end

  describe '.with_writable_all' do
    it 'changes all connections' do
      expect(Book).to connect_to('main_readonly.sqlite3')
      expect(Comment).to connect_to('comment_readonly.sqlite3')
      SwitchPoint.with_writable_all do
        expect(Book).to connect_to('main_writable.sqlite3')
        expect(Comment).to connect_to('comment_writable.sqlite3')
      end
    end
  end
end
