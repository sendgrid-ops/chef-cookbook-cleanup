# TODO - Clean this up. At least it works.
require 'semantic'
require 'chefclean/knifecookbook'

module ChefClean
  def ChefClean.backup(semantic_delimiter='minor', cookbooks=[], path='./backup')
    if cookbooks.length > 0
      cookbook_names = cookbooks
    else
      cookbook_names = ChefClean::KnifeCookbook.list
    end
    cookbook_names.each { |cookbook_name|
      puts "COOKBOOK: #{cookbook_name}"
      cookbook_versions = KnifeCookbook.show cookbook_name
      puts 'ALL VERSIONS:'
      puts cookbook_versions
      revision_lines = separate_revision_lines(cookbook_versions, semantic_delimiter)
      puts 'BACKED UP VERSIONS:'
      revision_lines.each { |revision_line|
        revision_line.shift
        revision_line.each { |cookbook_version|
          puts cookbook_version
          KnifeCookbook.backup_cookbook(cookbook_name, cookbook_version, path)
        }
      }
      puts "\n"
    }
  end

  def ChefClean.purge(delete=false, semantic_delimiter='minor', cookbooks=[])
    if !delete
      puts "***** DRY RUN *****"
    end
    if cookbooks.length > 0
      cookbook_names = cookbooks
    else
      cookbook_names = ChefClean::KnifeCookbook.list
    end
    cookbook_names.each { |cookbook_name|
      puts "COOKBOOK: #{cookbook_name}"
      cookbook_versions = KnifeCookbook.show cookbook_name
      puts 'VERSIONS:'
      puts cookbook_versions
      revision_lines = separate_revision_lines(cookbook_versions, semantic_delimiter)
      if delete
        puts 'DELETING VERSIONS:'
      else
        puts 'WOULD DELETE:'
      end
      revision_lines.each { |revision_line|
        revision_line.shift
        revision_line.each { |cookbook_version|
          puts cookbook_version
          if delete
            KnifeCookbook.delete(cookbook_name, cookbook_version)
          end
        }
      }
      puts "\n"
    }
  end


  # Given:
  # [2.1.0, 1.2.0, 1.1.2, 1.1.1, 1.1.0, 0.1.0]
  # Major
  # [[2.1.0], [1.2.0, 1.1.2, 1.1.1, 1.1.0], [0.1.0]]
  # Minor
  # [[2.1.0], [1.2.0], [1.1.2, 1.1.1, 1.1.0], [0.1.0]]
  def ChefClean.separate_revision_lines(cookbook_versions_arr, semantic_delimiter='minor')
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
