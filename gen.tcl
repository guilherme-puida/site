#!/usr/bin/env tclsh

package require fileutil

proc > {content args} {
  set filepath [file join {*}$args]
  file mkdir [file dirname $filepath]
  set fd [open $filepath w]
  puts -nonewline $fd $content 
  close $fd
}

proc = {origin args} {
  set dest [file join {*}$args]
  file mkdir [file dirname $dest]
  file copy -force $origin $dest
}

proc chext {curfile ext} {
  return "[file rootname $curfile].$ext"
}

proc renderhtml {title content} {
  return [subst {
    <!DOCTYPE html>
    <html>
      <head>
        <link rel="stylesheet preload" href="/static/styles.css" as="style">
        <link rel="icon" href="/static/favicon-32x32.png" width="32" height="32">
        <meta name="color-scheme" content="light dark">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <meta charset="utf-8">
        <title>$title</title>
      </head>
      <body>
        <nav>
          <a href="/">index</a>
          <a href="/about.html">about</a>
        </nav>
        $content
        <footer>
          <a href="https://github.com/guilherme-puida">github</a>
          <a href="mailto:guilherme@puida.xyz">mail</a>
          <small>$::commithash</small>
        </footer>
      </body>
    </html>
  }]
}

proc renderdate {date} {
  return [subst {<time datetime="$date">$date</time>}]
}

proc renderpost {filepath title date {updated ""}} {
  if {$updated != ""} {
    set updated "| [renderdate $updated]"
  }

  set posthtml [exec pandoc --highlight-style=monochrome $filepath]

  set content [subst {
    <article>
      <hgroup>
        <h1>$title</h1>
        <p>[renderdate $date] $updated</p>
      </hgroup>

      $posthtml
    </article>
  }]

  return [renderhtml "$title | puida.xyz" $content]
}

proc renderindex {posts} {
  set postlist {}
  foreach post $posts {
    lassign $post path title date
    lappend postlist [subst {<li><a href="[chext $path html]">[renderdate $date] / $title</a></li>}]
  }

  set content [subst {
    <main>
      <h1>hi! i'm guilherme</h1>
      <p>
        i'm a software engineer from brazil.
        i like talking about functional programming, low-js websites and math rock
      </p>

      <h2>posts</h2>
      <ul>
        [join $postlist "\n"]
      </ul>
    </main>
  }]

  return [renderhtml puida.xyz $content]
}

proc renderabout {} {
  return [renderhtml "about | puida.xyz" {
    <main>
      <h1>about me</h1>
      <p>
        i currently work as a junior engineer doing fullstack development using
        angular, spring boot and flutter. i'm also a full-time student at UnB
        (Universidade de Brasília).
      </p>

      <h2>work history</h2>
      <ul>
        <li>09-2022 to now: junior fullstack engineer @ <a href="https://placeti.com.br">placeti</a></li>
        <li>03-2023 to 09-2022: software engineering intern @ <a href="https://www.linkedin.com/company/cb-lab/">cblab</a></li>
        <li>09-2021 to 03-2022: software engineering intern @ <a href="https://placeti.com.br">placeti</a></li>
      </ul>

      <h2>music</h2>
      <p>in alphabetical order, here are my favorite artists right now.</p>
      <ul>
        <li>chico buarque</li>
        <li>chon</li>
        <li>codinome winchester</li>
        <li>loqto</li>
        <li>tide/edit</li>
      </ul>

      <h2>links</h2>
      <ul>
        <li><a href="https://github.com/guilherme-puida">github</a></li>
        <li><a href="https://last.fm/user/guilherme-puida">last.fm</a></li>
        <li><a href="https://linkedin.com/in/guilherme-puida">linkedin</a></li>
        <li><a href="https://mastodon.social/@puida">mastodon</a></li>
        <li><a href="mailto:guilherme@puida.xyz">mail</a></li>
      </ul>
    </main>
  }]
}

proc render404 {} {
  return [renderhtml {oops | puida.xyz} {<main><h1>you are not supposed to be here.</h1><p><a href="/">go back home</a></p></main>}]
}

proc isFile f {
  return [file isfile $f]
}

variable commithash [exec git rev-parse --short HEAD]

set posts {
  {posts/three-body-problem.md {The Three Body Problem} 2024-01-03}
  {posts/deleting-one-hundred-thousand-loc.md {Deleting 100K lines of code} 2023-10-23}
  {posts/pushing-empty-commits.md {Pushing empty commits} 2023-10-21}
  {posts/blogging-with-tcl.md {Blogging with Tcl} 2023-08-07}
}

> [renderindex $posts] dist index.html
> [renderabout] dist about.html
> [render404] dist 404.html

foreach post $posts {
  > [renderpost {*}$post] dist [chext [lindex $post 0] html]
}

foreach static [fileutil::find static isFile] {
  = $static dist/$static
}
