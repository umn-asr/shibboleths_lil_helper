module Slh::ClassMethods
  @@strategies = []
  def strategies; @@strategies; end


  ##########################
  # CORE API METHODS BEGIN #
  ##########################
  def for_strategy(strategy_sym, &block)
    @@strategies << Slh::Models::Strategy.new(strategy_sym, &block)
  end

  def clone_strategy_for_new_idp(existing_s, new_s, new_idp_url)
    existing_strategy = self.strategies.detect {|x| x.name == existing_s}
    raise "The specified strategy, #{existing_s}, does not exist" if existing_strategy.nil?
    raise "The new strategy,#{new_s}, already exists" if self.strategies.detect {|x| x.name == new_s}
    new_strategy = existing_strategy.clone
    new_strategy.idp_metadata_url = new_idp_url
    new_strategy.instance_variable_set(:@name, new_s)
    @@strategies << new_strategy
  end
  ########################
  # CORE API METHODS END #
  ########################

  def config_dir
    'shibboleths_lil_helper'
  end

  def config_file
    File.join self.config_dir,'config.rb'
  end

  @@is_loaded = false
  def load_config
    unless @@is_loaded
      Slh.command_line_output "Loading #{Slh.config_file}"
      begin
        require Slh.config_file
      rescue LoadError
        Slh.command_line_output "No #{Slh.config_file} found, exiting...Are you sure you are running this command from the right working directory?",
          :highlight => :red,
          :exit => true
      end
      if Slh.strategies.empty?
        Slh.command_line_output "No strategies found in #{Slh.config_file}, you should add some, exiting...",
          :highlight => :red,
          :exit => true
      end
      Slh.strategies.each do |strategy|
        begin
          strategy.key_originator_site
        rescue Slh::Models::Strategy::KeyOriginatorNotSpecified => e
          Slh.command_line_output "Strategy: #{strategy.name} DOES NOT specify 'set :is_key_originator, true' on any site--all strategies must.",
            :highlight => :red,
            :exit => true
        end
      end
      @@is_loaded = true
    end
  end
  def command_line_output(msg,*args)
    options = args.extract_options!
    s=msg
    unless options[:highlight].blank?
      case options[:highlight]
      when :green
        s="\e[1;32m#{s}\e[0m"
      when :red
        s="\e[1;31m#{s}\e[0m"
      else
        s="\e[1;31m#{s}\e[0m"
      end
    end
    unless options[:exception].blank?
      s << "Exception = #{options[:exception].class.to_s}, message=#{options[:exception].message}"
    end
    puts s 
    if options[:exit]
      exit
    end
  end
end
