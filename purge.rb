# TODO - Clean this up. At least it works.
require 'semantic'

# Grabs all cookbooks, iterates thorugh and does cleanup
def main(delete)
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
				if delete
					delete_cookbook(cookbook_name, cookbook_version)
				end
			}
		}
		puts "\n"
	}
end

# Only acts on given set of cookbooks
def main2(delete, backup)
	cookbook_names = ['sendgrid_chef_client', 'sendgrid_minitest-handler']
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
				if backup
					backup_cookbook(cookbook_name, cookbook_version)
				end
				if delete
					delete_cookbook(cookbook_name, cookbook_version)
				end
			}
		}
		puts "\n"
	}

end

def test()
	cookbook_name = 'sendgrid_yum_sendgrid'
	cookbook_versions = get_cookbook_versions_arr cookbook_name
	revision_lines = separate_revision_lines(cookbook_versions)
	revision_lines.each { |revision_line|
		revision_line.shift
		revision_line.each { |cookbook_version|
			puts cookbook_version
			backup_cookbook(cookbook_name, cookbook_version)
		}
	}
end

def backup_cookbook(name, version, path='/Users/jakepelletier/Projects/chef-cookbook-purge/backup')
	`knife cookbook download #{name} #{version} -d #{path}/#{name}/`
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
# 0.2.39
# 0.2.38
# 0.2.37
# 0.2.36
# 0.2.35
# 0.2.34
# 0.2.33
# 0.2.32
# 0.2.24
# 0.2.23
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
	revision_lines << cur_revision_line
	return revision_lines
end

def delete_cookbook(name, version)
	`knife cookbook delete -y #{name} #{version}`
end

#main2(delete=false, backup=false)
test
