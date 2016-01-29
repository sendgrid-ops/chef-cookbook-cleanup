# TODO - Clean this up. At least it works.
require 'semantic'

class Cookbook
	@name = nil
	@versions = []
end

module CookbookPurge
	def CookbookPurge.main(delete)
		cookbook_names = KnifeCookbook.list
		cookbook_names.each { |cookbook_name|
			puts "COOKBOOK: #{cookbook_name}"
			cookbook_versions = KnifeCookbook.show cookbook_name
			puts 'VERSIONS:'
			puts cookbook_versions
			revision_lines = separate_revision_lines(cookbook_versions)
			puts 'DELETED VERSIONS:'
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

	# Only acts on given set of cookbooks
	def CookbookPurge.main2(delete, backup, cookbook_names=nil)
		cookbook_names = ['sendgrid_chef_client', 'sendgrid_minitest-handler']
		cookbook_names.each { |cookbook_name|
			puts "COOKBOOK: #{cookbook_name}"
			cookbook_versions = get_cookbook_versions_arr cookbook_name
			puts 'VERSIONS:'
			puts cookbook_versions
			revision_lines = separate_revision_lines(cookbook_versions)
			puts 'DELETED VERSIONS:'
			revision_lines.each { |revision_line|
			}
			puts "\n"
		}
	end

	def CookbookPurge.parse_newest_patches(version_list)
		newest_patches = []
		last_version = nil
		version_list.each{ |version|
			sem_version = Semantic::Version.new version
			if (!last_version.nil?)
				if (!(sem_version.major == last_version.major && sem_version.minor == last_version.minor))
					newest_patches << version
				end
			end
			last_version = sem_version
		}
		return newest_patches
	end

	# Deletes all cookbooks in list except the newest
	def CookbookPurge.delete_versions(cookbook_name, version_list, backup, delete)
		version_list.shift
		version_list.each { |version|
			puts version
			if backup
				backup_cookbook(cookbook_name, cookbook_version)
			end
			if delete
				delete_cookbook(cookbook_name, cookbook_version)
			end
		}
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
	def CookbookPurge.separate_revision_lines(cookbook_versions_arr)
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
end

#main2(delete=false, backup=false)
#test

# Library
module KnifeCookbook
	DOWNLOAD_PATH='./backup'

	def KnifeCookbook.download(name, version, path=DOWNLOAD_PATH)
		`knife cookbook download #{name} #{version} -d #{path}/#{name}/`
	end

	def KnifeCookbook.list
		`knife cookbook list |awk '{print $1}'`.split(/\n/)
	end

	def KnifeCookbook.delete(name, version)
		`knife cookbook delete -y #{name} #{version}`
	end

	def KnifeCookbook.show(name)
		# .drop(1) to remove the cookbook_name from the top of the array
		`knife cookbook show #{name} |tr " " "\n" |sed '/^\s*$/d'`.split(/\n/).drop(1)
	end
end
