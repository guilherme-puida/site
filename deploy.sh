#!/bin/bash

sitetarball=site.tar.gz

hugo --minify
tar -C public -cvz . > "$sitetarball"
hut pages publish -d puida.srht.site --site-config siteconfig.json "$sitetarball"
