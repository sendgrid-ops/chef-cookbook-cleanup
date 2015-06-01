require 'semantic'

def main()
  cookbook_names = get_cookbook_names_arr
  cookbook_names.each { |cookbook_name|
    puts "COOKBOOK: #{cookbook_name}"
    cookbook_versions = get_cookbook_versions_arr cookbook_name
    puts 'VERSIONS:'
    puts cookbook_versions
    revision_lines = separate_revision_lines(cookbook_versions)
    puts 'DELETED VERSIONS:'
    revision_lines.each { |revision_line|
      revision_line.shift
      revision_line.each { |cookbook_version|
        puts cookbook_version
      }
    }
    puts "\n"
  }
end

def test()
  filterd_cookbook_versions = get_cookbook_versions_arr 'filterd'
  puts filterd_cookbook_versions
  revision_lines = separate_revision_lines(filterd_cookbook_versions)
  revision_lines.each { |revision_line|
  }
end

def get_cookbook_names_arr
  `knife cookbook list |awk '{print $1}'`.split(/\n/)
end

def get_cookbook_versions_arr(cookbook_name)
  # .drop(1) to remove the cookbook_name from the top of the array
  `knife cookbook show #{cookbook_name} |tr " " "\n" |sed '/^\s*$/d'`.split(/\n/).drop(1)
end

# Given:
# [2.1.0, 1.1.2, 1.1.1, 0.1.0]
# returns:
# [[2.1.0], [1.1.2, 1.1.1], [0.1.0]]
# Looks gross, I should tidy up the if/else logic
def separate_revision_lines(cookbook_versions_arr)
  revision_lines = []
  cur_revision_line = []
  last_version = nil
  for cookbook_version in cookbook_versions_arr do
    version = Semantic::Version.new cookbook_version
    if (last_version.nil?)
      cur_revision_line << version
      last_version = version
    elsif (version.major != last_version.major)
      revision_lines << cur_revision_line
      cur_revision_line = []
      cur_revision_line << version
      last_version = version
    elsif (version.minor != last_version.minor)
      revision_lines << cur_revision_line
      cur_revision_line = []
      cur_revision_line << version
      last_version = version
    else
      cur_revision_line << version
      last_version = version
    end
  end
  return revision_lines
end

main()
