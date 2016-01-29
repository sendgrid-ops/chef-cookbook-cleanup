# Library
module ChefClean
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
end
