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

## Setup
```
RUBYLIB="/Users/jakepelletier/Projects/chef/chef-cookbook-purge/lib"
export RUBYLIB
./bin/chefclean
```

## Architecture
### UI
bin/chefclean
`chefclean <command>`

```
chefclean backup <semantic_delimiter>

chefclean backup minor
chefclean backup major
```

```
TO IMPLEMENT:
chefclean backup <semantic_delimiter> <path>
```

```
chefclean purge <semantic_delimiter> <delete>

chefclean purge major false
chefclean purge minor true
```

```
TO IMPLEMENT:
chefclean purge <semantic_delimiter> <delete> <cookbook_name1> <cookbook_name2>...
```


lib/chefclean.rb
`def backup`

`def purge(cookbooks=[])`
