+++
title = "Deleting 100K lines of code"
date = 2023-10-23
description = "How I deleted 100 thousand lines of code"
+++

I recently merged a branch that touched over 2600 files and deleted 100K lines
of code. **In a project with no tests**.

![Screenshot of the Gitlab interface showing the amount of changes in the merge request.](/img/changes.png)

## Why

This was part of a larger refactoring effort started when we decided to migrate
from GraphQL back to REST. The reason to migrate is not in scope for this blog
post, but it suffices to say that people didn't quite like writing resolvers.

Thankfully, the project was reasonably modularized and almost all new features
didn't use GraphQL. However, the code handling those few old scenarios was
still there, and it was impacting both bundle size and build time.

I've been wanting to delete all this cruft for a while now. I had an unusually
quiet week, so I decided to be the one that goes around deleting old code when
everyone is afraid to do so.

## How

The project is a medium-sized (around 500 thousand lines of code) web
application built with Spring Boot (using Kotlin) and Angular. The same
repository contains both front-end and back-end code, which meant that all
changes could be coordinated and done in a single merge. This avoids nasty
synchronization problems, and was quite nice not having to juggle between two
separate projects to do a large refactor like this.

However, the front-end code was only recently imported into the main
repository, and unfortunately we lost the git history when merging the two
codebases. This meant that I had no idea when a front-end file was last
touched, making the process of figuring out which features were obsolete
harder.

## The process

My first instinct was to use some sort of automated tool to check which classes
were not used. However, this fails in the front-end due to classes being
imported (and used) in routes, even if those routes are not accessible.

I thought about deleting all routes I believed were unused, but this
immediately made typescript barf a ton of errors and just give up compiling.
I'm not sure what exactly caused this, but I suspect it has something to do
with modules or other Angular magic that happens behind the scenes.

This meant that I would have to ask around other teams to see which code was
garbage and what was still in use. My colleagues were very understanding and
gave me an overview of what was new and what was old.

After obtaining a big picture view of the entire codebase, I started to delete
routes I believed to be unused. This was the hardest part of the whole process,
since I was really afraid of breaking something. I spend one whole day doing this.

After deleting most routes, I could finally use some automated tools to see
what I could remove. I used [ts-prune][^1] to show unused exports and went trough
the list manually deleting everything that seemed to related to the old project
structure. This greatly sped up my work, and I was able to remove tons of files
in one go.

[ts-prune]: https://github.com/nadeesha/ts-prune
[^1]: Which is now in maintenance mode. It served me well, but YMMV.

After cleaning up most of the cruft, I turned my attention to the few places
where we still used old code in new features. After making some changes to both
the back-end and front-end (mostly adding some new REST routes and hooking up
services to controllers) I was able to completely remove the GraphQL
dependencies from the front-end project.

This meant that I could now remove all back-end GraphQL code, also removing the
dependencies as well.

This whole process took me about three days of work _(and copious amounts of
coffee)_.

## Results

I ended up deleting around 100 thousand lines of code and about 2600 files.
This is not that surprising considering the huge amount of `.graphqls` files we
had defined. Resolvers and other GraphQL plumbing also takes a ton of space,
and the tendency to put every class in a separate file also inflates the amount
of files I had to touch.

In my machine, time to bring up the back-end server went from around 120
seconds down to 30 seconds. This was also not surprising, since most of the
startup time was spent doing Bean resolution for GraphQL resolvers.

All-in-all, I believe this has helped everyone on the team. Waiting up to two
minutes to see if a simple change worked has horrible, and I already got some
thank-you's for the effort :^).
