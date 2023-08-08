My previous blog was built using [astro](https://astro.build). While it worked
just fine, I was constantly lagging behind versions and dreaded the day
that the build process would suddenly stop working.

Since my blog was a super simple website, I decided to just make a simple site
generator for myself (and I also thought this was going to be a fun experience).

## The begginings

I knew I wanted to keep authoring content in a markup language, since I'm not a
big fan of writing HTML by hand. A somewhat acceptable (and easily accessible) option is
[markdown](https://en.wikipedia.org/wiki/Markdown).

Since I was already a [pandoc](https://github.com/jgm/pandoc) user ^[I use it
to write school assignments and work presentations.], my first instict was writing
the generator in bash. This turned out to not be a great idea, since the lack
of basic data structures and constant need to quote variables to avoid disaster
made the whole process tedious.

Since bash was out of the question, I needed a language that:

1. Portable.
2. Had sane variable usage (no quoting).
3. Had support for data structures like lists and dictionaries.
4. Had convenient functions for interacting with command line applications.

While searching for a replacement, I came across the Tool Command Language
(Tcl). It's a simple but surprisingly expressive language, and it checked all
the requirements for a bash replacement.

So I went ahead and implemented this very website using Tcl and Pandoc.

## Using Tcl

This will not be a tutorial on the Tcl language, but i'll show some things that
I think are interesting and useful when building webpages.

### Templating with `subst`

Normally, commands and variables are not substituted when used inside bracket literals.
However, we can use the `subst` command to make the substitutions anyways. This makes for an easy (but very powerful) templating language.

```tcl
proc renderhtml {title content} {
  return [subst {
    <html>
      <head>
        <title>$title</title>
      </head>
      <body>
        $content
      </body>
    </html>
  }]
}
```

### Rendering Markdown and Interating with the CLI

While `tcllib` has a markdown module, I still wanted to use pandoc to do the
markdown to HTML conversion. This was as simple as using `exec` to capture
pandoc's stdout and use it directly in the `subst` templates.


```tcl
proc renderpost {filepath title} {
  set posthtml [exec pandoc --highlight-style=monochrome $filepath] 

  return renderhtml [$title [subst {<article>$posthtml</article>}]]
}
```

### A DSL for page building

I defined a few helper procedures to avoid managing file descriptors all over
the place. Since procedures can be named almost anything, I decided to use
funny haha names to make me happy.

```tcl
proc > {content args} {
  # Writes content to destination,
  set filepath [file join {*}$args]
  file mkdir [file dirname $filepath]
  set fd [open $filepath w]
  puts -nonewline $fd $content
  close $fd
}

proc = {origin args} {
  # Copies file to destination.
  set dest [file join {*}$args]
  file mkdir [file dirname $dest]
  file copy -force $origin $dest
}
```

Using those procedures, building posts is really easy:

```tcl
# let chext be a procecure that changes the extension

# let posts be a list of lists, where the first element of every
# inner list is a path to a markdown file.

foreach post $posts {
  > [renderpost {*}$post] dist [chext [lindex $post 0] html]
}
```

## Final touches

With the build script in place, I just needed to add some css and the blog was
ready! The whole ordeal took a day or so to complete, and that includes the
time to figure out how Tcl works and deciding how I would structure the
content.

The complete script is available [on my github
account](https://github.com/guilherme-puida/site). I'm not a Tcl expert, so
there is probably a better way to structure and write the build script. If you
have any suggestions, [shoot me an email](mailto:guilherme@puida.xyz) or open
an issue on the repository.

See you next time!
