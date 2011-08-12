module Slh
  class Cli # Command Line Interface
    def self.execute
      # TODO: handle params
      # if File.directory?('shibboleths_lil_helper')

      # else
      #   FileUtils.mkdir_p('shibboleths_lil_helper')
      # end
      Slh.strategies.each do |s|
        puts 'HI buck'
        s.generate_config
      end
    end
  end
end
