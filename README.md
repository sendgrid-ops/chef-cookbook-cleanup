# Chef Clean
This serves to delete cookbooks off the chef-server in a more dynamic way.  
Currently defaults to keeping the last version in each minor revision line.  

Example:  
```
Given:
[2.1.0, 1.2.0, 1.1.2, 1.1.1, 1.1.0, 0.1.0]

Purge/backup based on MAJOR revision deletes:
[1.1.2, 1.1.1, 1.1.0]

Purge/backup based on MINOR revision deletes:
[1.1.1, 1.1.0]
```

## Setup
```
RUBYLIB="/Users/jakepelletier/Projects/chef/chef-cookbook-purge/lib"
export RUBYLIB
./bin/chefclean
```

## Output
```
$ ./bin/chefclean purge major false
I, [2016-01-29T14:01:08.082378 #16426]  INFO -- : COOKBOOK: apache2
I, [2016-01-29T14:01:09.168337 #16426]  INFO -- : VERSIONS:
I, [2016-01-29T14:01:09.168399 #16426]  INFO -- : 3.1.0
I, [2016-01-29T14:01:09.168414 #16426]  INFO -- : 3.0.0
I, [2016-01-29T14:01:09.168424 #16426]  INFO -- : 2.0.1
I, [2016-01-29T14:01:09.168436 #16426]  INFO -- : 1.11.0
I, [2016-01-29T14:01:09.168446 #16426]  INFO -- : 1.10.4
I, [2016-01-29T14:01:09.168458 #16426]  INFO -- : 1.9.6
I, [2016-01-29T14:01:09.168468 #16426]  INFO -- : 1.6.6
I, [2016-01-29T14:01:09.168479 #16426]  INFO -- : 1.1.16
I, [2016-01-29T14:01:09.168603 #16426]  INFO -- : WOULD DELETE:
I, [2016-01-29T14:01:09.168643 #16426]  INFO -- : 3.0.0
I, [2016-01-29T14:01:09.168660 #16426]  INFO -- : 1.10.4
I, [2016-01-29T14:01:09.168703 #16426]  INFO -- : 1.9.6
I, [2016-01-29T14:01:09.168735 #16426]  INFO -- : 1.6.6
I, [2016-01-29T14:01:09.168788 #16426]  INFO -- : 1.1.16
I, [2016-01-29T14:01:09.168800 #16426]  INFO -- :
```


## Architecture
### CLI
bin/chefclean

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

### Library
lib/chefclean.rb
```
def backup
```

```
def purge(cookbooks=[])
```
