# Chef Clean
This serves to delete cookbooks off the chef-server in a more dynamic way.  
Currently defaults to keeping the last version in each minor revision line.  

Example:  
```
Given:
apid [2.1.0, 1.1.2, 1.1.1, 0.1.0]
Deletes:
apid [1.1.1]
```

## Architecture
### UI
bin/chefclean
`chefclean <command>`

`chefclean backup`

`chefclean purge`

`chefclean purge <cookbook_name1> <cookbook_name2>...`

lib/chefclean.rb
`def backup`

`def purge(cookbooks=[])`
