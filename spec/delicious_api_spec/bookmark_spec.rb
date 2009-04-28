require File.dirname(__FILE__) + '/../spec_helper'

include DeliciousApi

describe Bookmark do

  configure_wrapper

  freeze_time # Freezing time for better testing

  describe "an instance of the Bookmark class" do

    def build_bookmark(opt={})
      options = { :description => 'Yahoo!', :extended => 'My favorite site ever',
                  :hash => '2f9704c729e7ed3b41647b7d0ad649fe', :meta => '77e1ec24a43bae61fb67586649683d30',
                  :others => '433', :tags => 'yahoo web search', :time => Time.now.iso8601 }
      Bookmark.new 'http://www.yahoo.com/', options.merge(opt)
    end

    before(:each) do
      @bookmark = build_bookmark
    end

    it "should have a href attribute" do
      @bookmark.href.should == 'http://www.yahoo.com/'
    end

    it "should have a description attribute" do
      @bookmark.description.should  == 'Yahoo!'
    end

    it "should have an extended description attribute" do
      @bookmark.extended.should == 'My favorite site ever'
    end

    it "should have a hash attribute" do
      @bookmark.hash.should == '2f9704c729e7ed3b41647b7d0ad649fe'
    end

    it "should have a meta attribute" do
      @bookmark.meta.should == '77e1ec24a43bae61fb67586649683d30'
    end

    it "should have an others attribute" do
      @bookmark.others.should == '433'
    end

    it "should have an array of tags" do
      @bookmark.tags.should == %w[yahoo web search]
    end

    it "should have a time attribute" do
      @bookmark.time.iso8601.should == Time.now.iso8601
    end

    it "should be 'shared' by default" do
      @bookmark.shared.should == true
    end

    it "should allow to specify an array of tags or an actual Time instance as a parameter" do
      @bookmark = build_bookmark :tags => %w[array of tags],
                                 :time => Time.now
      @bookmark.tags.should  == %w[array of tags]
      @bookmark.time.should  == Time.now
    end

    describe "having a save method" do

      it "should do it succesfully" do
        @bookmark.wrapper.should_receive(:add_bookmark).
                  with('http://www.yahoo.com/', 'Yahoo!',
                      {:shared => 'yes', :tags => 'yahoo web search', :dt => Time.now.iso8601,
                       :extended => 'My favorite site ever', :replace => 'no' }).
                  and_return(true)
        @bookmark.save
      end

      it "should force replacement through a bang method" do
        @bookmark.wrapper.should_receive(:add_bookmark).
                  with('http://www.yahoo.com/', 'Yahoo!',
                      {:shared => 'yes', :tags => 'yahoo web search', :dt => Time.now.iso8601,
                       :extended => 'My favorite site ever', :replace => 'yes' }).
                  and_return(true)
        @bookmark.save!
      end

      it "should raise an exception when href is nil" do
        @bookmark.href = nil
        lambda { @bookmark.save }.should raise_error(MissingAttributeError)
      end

      it "should raise an exception when description is nil" do
        @bookmark.description = nil
        lambda { @bookmark.save }.should raise_error(MissingAttributeError)
      end

      it "should raise OperationFailed" do
        @bookmark.wrapper.should_receive(:add_bookmark).and_return(false)
        lambda { @bookmark.save }.should raise_error(OperationFailed)
      end

    end

    describe "having a fetch suggested tags method" do

      it "should do it succesfully" do
        @bookmark.wrapper.should_receive(:get_suggested_tags_for_url).with('http://www.yahoo.com/')
        @bookmark.suggested_tags
      end

      it "should raise an exception on missing attributes" do
        @bookmark.href = nil
        lambda { @bookmark.suggested_tags }.should raise_error(MissingAttributeError)
      end

    end

    describe "having a destroy method" do

      it "should do it succesfully" do
        @bookmark.wrapper.should_receive(:delete_bookmark).with('http://www.yahoo.com/').and_return(true)
        @bookmark.destroy
      end

      it "should raise an exception on missing attributes" do
        @bookmark.href = nil
        lambda { @bookmark.destroy }.should raise_error(MissingAttributeError)
      end

      it "should raise OperationFailed" do
        @bookmark.wrapper.should_receive(:delete_bookmark).and_return(false)
        @bookmark.destroy
      end
    end

  end

  describe "Bookmark class" do

    it "should find a subset of all the bookmarks (start point and limit) filtered by any combination of tag, starting date and ending date" do
      Base.wrapper.should_receive(:get_bookmarks_by_date).
           with({:dt => Time.now.iso8601, :tag => 'yahoo web search',
                 :url => 'http://www.yahoo.com/', :hashes => 'hash1 hash2 hash3', :meta => 'yes' })
      Bookmark.find :url => 'http://www.yahoo.com/', :tags => %w[yahoo web search],
                    :date => Time.now, :hashes => %w[hash1 hash2 hash3], :meta => true
    end

    describe "fetching recent bookmarks" do
      it "should allow to limit and filter (by tag) the results" do
        Base.wrapper.should_receive(:get_recent_bookmarks).with(:tag => 'yahoo', :limit => 10)
        Bookmark.recent :tag => 'yahoo', :limit => 10
      end
      it "should default limit size to 10" do
        Base.wrapper.should_receive(:get_recent_bookmarks).with(:tag => 'yahoo', :limit => 10)
        Bookmark.recent :tag => 'yahoo'
      end
    end

    describe "fetching all the bookmarks" do
      it "should allow to limit and filter (by tag) the results" do
        Base.wrapper.should_receive(:get_all_bookmarks).with(:tag => 'yahoo', :limit => 10)
        Bookmark.all :tag => 'yahoo', :limit => 10
      end
      it "should allow to filter the results by a date range" do
        start_time = Time.now - 2
        end_time = Time.now
        Base.wrapper.should_receive(:get_all_bookmarks).with(:fromdt => start_time.iso8601, :todt => end_time.iso8601)
        Bookmark.all :start_time => start_time, :end_time => end_time
      end
    end

  end

end