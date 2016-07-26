# TODO - Clean this up. At least it works.
require 'logger'
require 'semantic'

require_relative 'knifecookbook'

module ChefClean
  class ChefClean
    def initialize(logger)
      @logger = logger
    end

    def build
      logger = Logger.new(STDOUT)
      ChefClean.new(logger)
    end

    def backup(semantic_delimiter='minor', path='./backup', cookbooks=[])
      if cookbooks.length > 0
        cookbook_names = cookbooks
      else
        cookbook_names = KnifeCookbook.list
      end
      cookbook_names.each { |cookbook_name|
        @logger.info("COOKBOOK: #{cookbook_name}")
        cookbook_versions = KnifeCookbook.show cookbook_name
        @logger.info('ALL VERSIONS:')
        cookbook_versions.each { |cookbook_version|
          @logger.info(cookbook_version.to_s)
        }
        revision_lines = separate_revision_lines(cookbook_versions, semantic_delimiter)
        @logger.info('BACKED UP VERSIONS:')
        revision_lines.each { |revision_line|
          revision_line.shift
          revision_line.each { |cookbook_version|
            @logger.info(cookbook_version.to_s)
            KnifeCookbook.download(cookbook_name, cookbook_version, path)
          }
        }
        @logger.info('')
      }
    end

    def purge(delete=false, semantic_delimiter='minor', cookbooks=[])
      if !delete
        @logger.info("***** DRY RUN *****")
      end
      if cookbooks.length > 0
        cookbook_names = cookbooks
      else
        cookbook_names = KnifeCookbook.list
      end
      cookbook_names.each { |cookbook_name|
        @logger.info("COOKBOOK: #{cookbook_name}")
        cookbook_versions = KnifeCookbook.show cookbook_name
        @logger.info('ALL VERSIONS:')
        cookbook_versions.each { |cookbook_version|
          @logger.info(cookbook_version.to_s)
        }
        revision_lines = separate_revision_lines(cookbook_versions, semantic_delimiter)
        if delete
          @logger.info('DELETING VERSIONS:')
        else
          @logger.info('WOULD DELETE:')
        end
        revision_lines.each { |revision_line|
          revision_line.shift
          revision_line.each { |cookbook_version|
            @logger.info(cookbook_version.to_s)
            if delete
              KnifeCookbook.delete(cookbook_name, cookbook_version)
            end
          }
        }
        @logger.info('')
      }
    end


    # Given:
    # [2.1.0, 1.2.0, 1.1.2, 1.1.1, 1.1.0, 0.1.0]
    # Major
    # [[2.1.0], [1.2.0, 1.1.2, 1.1.1, 1.1.0], [0.1.0]]
    # Minor
    # [[2.1.0], [1.2.0], [1.1.2, 1.1.1, 1.1.0], [0.1.0]]
    def separate_revision_lines(cookbook_versions_arr, semantic_delimiter='minor')
      revision_lines = []
      cur_revision_line = []
      last_version = nil
      for cookbook_version in cookbook_versions_arr do
        version = Semantic::Version.new cookbook_version
        if (last_version.nil?)
          cur_revision_line << version
        elsif (version.major != last_version.major)
          revision_lines << cur_revision_line
          cur_revision_line = []
          cur_revision_line << version
        elsif (semantic_delimiter == 'minor' && version.minor != last_version.minor)
          revision_lines << cur_revision_line
          cur_revision_line = []
          cur_revision_line << version
        else
          cur_revision_line << version
        end
        last_version = version
      end
      revision_lines << cur_revision_line
      return revision_lines
    end
  end
end
