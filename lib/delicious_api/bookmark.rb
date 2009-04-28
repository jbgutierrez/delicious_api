require File.dirname(__FILE__) + '/base'
require 'time'

module DeliciousApi
  class Bookmark < Base

    # The url of the bookmark
    attr_accessor :href

    # The description of the bookmark
    attr_accessor :description

    # Notes for the bookmark
    attr_accessor :extended

    # URL MD5
    attr_reader :hash

    # Change detection signature
    attr_reader :meta

    # TODO: Comment!!
    attr_reader :others

    # <tt>Array</tt> of tags for the bookmark
    attr_accessor :tags

    # A <tt>Time</tt> object determining the datestamp for the bookmark
    attr_accessor :time

    # A <tt>boolean</tt> determining whether the bookmark should be marked privated or shared
    attr_accessor :shared

    before_assign :tags, :filter_tags
    before_assign :time, :filter_time

    ##
    # Bookmark initialize method
    # ==== Parameters
    # * <tt>href</tt> - The url of the bookmark
    # * <tt>params</tt> - An optional <tt>Hash</tt> containing any combination of the instance attributes
    # ==== Result
    # An new instance of the current class
    def initialize(href, params = {})
      params.symbolize_keys!.assert_valid_keys(:href, :description, :extended, :hash, :meta, :others, :tags, :tag, :time, :shared)
      params.reverse_merge!(:href => href, :tags => params[:tag], :shared => true)
      assign params
    end

    # Saves the bookmark in del.icio.us
    # ==== Parameters
    # * <tt>replace</tt> - A <tt>boolean</tt> determining whether the bookmark should be replaced when it has already been posted
    def save(replace=false)
      validate_presence_of :href, :description
      options = pack_save_options.merge(:replace => replace ? 'yes' : 'no' )
      wrapper.add_bookmark(@href, @description, options) || raise(OperationFailed)
    end

    # Saves the bookmark in Delicious. If it has already been posted, forces replacement 
    # of the existing bookmark contents. (Same behaviour as save(true))
    def save!
      save(true)
    end

    # Deletes the bookmark from Delicious
    def destroy
      validate_presence_of :href
      wrapper.delete_bookmark @href || raise(OperationFailed)
    end

    # Retrieves an <tt>Array</tt> of suggested tag names from Delicious
    def suggested_tags
      validate_presence_of :href
      wrapper.get_suggested_tags_for_url @href
    end

    def self.find(options = {})
      options.assert_valid_keys(:url, :tags, :date, :hashes, :meta)
      Base.wrapper.get_bookmarks_by_date pack_find_options(options)
    end

    def self.recent(options = {})
      options.assert_valid_keys(:tag, :limit)
      options.reverse_merge!(:limit => 10)
      Base.wrapper.get_recent_bookmarks options
    end

    def self.all(options = {})
      options.assert_valid_keys(:tag, :limit, :start_time, :end_time)
      wrapper.get_all_bookmarks pack_all_options options
    end

    protected

    def filter_tags(tags) #:nodoc:
      tags.instance_of?(String) ? tags.split : tags
    end

    def filter_time(time) #:nodoc:
      time.instance_of?(String) ? Time.xmlschema(time) : time
    end

    def pack_save_options #:nodoc:
      opt = {}
      opt[:tags]     = @tags.nil? ? '' : @tags.join(' ')
      opt[:extended] = @extended               unless @extended.nil?
      opt[:dt]       = @time.iso8601           unless @time.nil?
      opt[:shared]   = @shared ? 'yes' : 'no'  unless @shared.nil?
      opt
    end

    def self.pack_find_options(options) #:nodoc:
      opt = {}
      opt[:url]    = options[:url]                 unless options[:url].nil?
      opt[:tag]    = options[:tags].join(' ')      unless options[:tags].nil?
      opt[:dt]     = options[:date].iso8601        unless options[:date].nil?
      opt[:hashes] = options[:hashes].join(' ')    unless options[:hashes].nil?
      opt[:meta]   = options[:meta] ? 'yes' : 'no' unless options[:meta].nil?
      opt
    end

    def self.pack_all_options(options) #:nodoc:
      opt = {}
      opt[:tag]    = options[:tag]                  unless options[:tag].nil?
      opt[:limit]  = options[:limit]                unless options[:limit].nil?
      opt[:fromdt] = options[:start_time].iso8601   unless options[:start_time].nil?
      opt[:todt]   = options[:end_time].iso8601     unless options[:end_time].nil?
      opt
    end

  end
end