// GENERATED CODE - DO NOT MODIFY BY HAND

part of md_proc.test.data.test_data;

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> specification
// **************************************************************************

final Map<String, String> _$specificationTests = <String, String>{
  r'''→foo→baz→→bim
''': r'''<pre><code>foo→baz→→bim
</code></pre>
''',
  r'''  →foo→baz→→bim
''': r'''<pre><code>foo→baz→→bim
</code></pre>
''',
  r'''    a→a
    ὐ→a
''': r'''<pre><code>a→a
ὐ→a
</code></pre>
''',
  r'''  - foo

→bar
''': r'''<ul>
<li>
<p>foo</p>
<p>bar</p>
</li>
</ul>
''',
  r'''- foo

→→bar
''': r'''<ul>
<li>
<p>foo</p>
<pre><code>  bar
</code></pre>
</li>
</ul>
''',
  r'''>→→foo
''': r'''<blockquote>
<pre><code>  foo
</code></pre>
</blockquote>
''',
  r'''-→→foo
''': r'''<ul>
<li>
<pre><code>  foo
</code></pre>
</li>
</ul>
''',
  r'''    foo
→bar
''': r'''<pre><code>foo
bar
</code></pre>
''',
  r''' - foo
   - bar
→ - baz
''': r'''<ul>
<li>foo
<ul>
<li>bar
<ul>
<li>baz</li>
</ul>
</li>
</ul>
</li>
</ul>
''',
  r'''#→Foo
''': r'''<h1>Foo</h1>
''',
  r'''*→*→*→
''': r'''<hr />
''',
  r'''- `one
- two`
''': r'''<ul>
<li>`one</li>
<li>two`</li>
</ul>
''',
  r'''***
---
___
''': r'''<hr />
<hr />
<hr />
''',
  r'''+++
''': r'''<p>+++</p>
''',
  r'''===
''': r'''<p>===</p>
''',
  r'''--
**
__
''': r'''<p>--
**
__</p>
''',
  r''' ***
  ***
   ***
''': r'''<hr />
<hr />
<hr />
''',
  r'''    ***
''': r'''<pre><code>***
</code></pre>
''',
  r'''Foo
    ***
''': r'''<p>Foo
***</p>
''',
  r'''_____________________________________
''': r'''<hr />
''',
  r''' - - -
''': r'''<hr />
''',
  r''' **  * ** * ** * **
''': r'''<hr />
''',
  r'''-     -      -      -
''': r'''<hr />
''',
  r'''- - - -    
''': r'''<hr />
''',
  r'''_ _ _ _ a

a------

---a---
''': r'''<p>_ _ _ _ a</p>
<p>a------</p>
<p>---a---</p>
''',
  r''' *-*
''': r'''<p><em>-</em></p>
''',
  r'''- foo
***
- bar
''': r'''<ul>
<li>foo</li>
</ul>
<hr />
<ul>
<li>bar</li>
</ul>
''',
  r'''Foo
***
bar
''': r'''<p>Foo</p>
<hr />
<p>bar</p>
''',
  r'''Foo
---
bar
''': r'''<h2>Foo</h2>
<p>bar</p>
''',
  r'''* Foo
* * *
* Bar
''': r'''<ul>
<li>Foo</li>
</ul>
<hr />
<ul>
<li>Bar</li>
</ul>
''',
  r'''- Foo
- * * *
''': r'''<ul>
<li>Foo</li>
<li>
<hr />
</li>
</ul>
''',
  r'''# foo
## foo
### foo
#### foo
##### foo
###### foo
''': r'''<h1>foo</h1>
<h2>foo</h2>
<h3>foo</h3>
<h4>foo</h4>
<h5>foo</h5>
<h6>foo</h6>
''',
  r'''####### foo
''': r'''<p>####### foo</p>
''',
  r'''#5 bolt

#hashtag
''': r'''<p>#5 bolt</p>
<p>#hashtag</p>
''',
  r'''\## foo
''': r'''<p>## foo</p>
''',
  r'''# foo *bar* \*baz\*
''': r'''<h1>foo <em>bar</em> *baz*</h1>
''',
  r'''#                  foo                     
''': r'''<h1>foo</h1>
''',
  r''' ### foo
  ## foo
   # foo
''': r'''<h3>foo</h3>
<h2>foo</h2>
<h1>foo</h1>
''',
  r'''    # foo
''': r'''<pre><code># foo
</code></pre>
''',
  r'''foo
    # bar
''': r'''<p>foo
# bar</p>
''',
  r'''## foo ##
  ###   bar    ###
''': r'''<h2>foo</h2>
<h3>bar</h3>
''',
  r'''# foo ##################################
##### foo ##
''': r'''<h1>foo</h1>
<h5>foo</h5>
''',
  r'''### foo ###     
''': r'''<h3>foo</h3>
''',
  r'''### foo ### b
''': r'''<h3>foo ### b</h3>
''',
  r'''# foo#
''': r'''<h1>foo#</h1>
''',
  r'''### foo \###
## foo #\##
# foo \#
''': r'''<h3>foo ###</h3>
<h2>foo ###</h2>
<h1>foo #</h1>
''',
  r'''****
## foo
****
''': r'''<hr />
<h2>foo</h2>
<hr />
''',
  r'''Foo bar
# baz
Bar foo
''': r'''<p>Foo bar</p>
<h1>baz</h1>
<p>Bar foo</p>
''',
  r'''## 
#
### ###
''': r'''<h2></h2>
<h1></h1>
<h3></h3>
''',
  r'''Foo *bar*
=========

Foo *bar*
---------
''': r'''<h1>Foo <em>bar</em></h1>
<h2>Foo <em>bar</em></h2>
''',
  r'''Foo *bar
baz*
====
''': r'''<h1>Foo <em>bar
baz</em></h1>
''',
  r'''Foo
-------------------------

Foo
=
''': r'''<h2>Foo</h2>
<h1>Foo</h1>
''',
  r'''   Foo
---

  Foo
-----

  Foo
  ===
''': r'''<h2>Foo</h2>
<h2>Foo</h2>
<h1>Foo</h1>
''',
  r'''    Foo
    ---

    Foo
---
''': r'''<pre><code>Foo
---

Foo
</code></pre>
<hr />
''',
  r'''Foo
   ----      
''': r'''<h2>Foo</h2>
''',
  r'''Foo
    ---
''': r'''<p>Foo
---</p>
''',
  r'''Foo
= =

Foo
--- -
''': r'''<p>Foo
= =</p>
<p>Foo</p>
<hr />
''',
  r'''Foo  
-----
''': r'''<h2>Foo</h2>
''',
  r'''Foo\
----
''': r'''<h2>Foo\</h2>
''',
  r'''`Foo
----
`

<a title="a lot
---
of dashes"/>
''': r'''<h2>`Foo</h2>
<p>`</p>
<h2>&lt;a title=&quot;a lot</h2>
<p>of dashes&quot;/&gt;</p>
''',
  r'''> Foo
---
''': r'''<blockquote>
<p>Foo</p>
</blockquote>
<hr />
''',
  r'''> foo
bar
===
''': r'''<blockquote>
<p>foo
bar
===</p>
</blockquote>
''',
  r'''- Foo
---
''': r'''<ul>
<li>Foo</li>
</ul>
<hr />
''',
  r'''Foo
Bar
---
''': r'''<h2>Foo
Bar</h2>
''',
  r'''---
Foo
---
Bar
---
Baz
''': r'''<hr />
<h2>Foo</h2>
<h2>Bar</h2>
<p>Baz</p>
''',
  r'''
====
''': r'''<p>====</p>
''',
  r'''---
---
''': r'''<hr />
<hr />
''',
  r'''- foo
-----
''': r'''<ul>
<li>foo</li>
</ul>
<hr />
''',
  r'''    foo
---
''': r'''<pre><code>foo
</code></pre>
<hr />
''',
  r'''> foo
-----
''': r'''<blockquote>
<p>foo</p>
</blockquote>
<hr />
''',
  r'''\> foo
------
''': r'''<h2>&gt; foo</h2>
''',
  r'''Foo

bar
---
baz
''': r'''<p>Foo</p>
<h2>bar</h2>
<p>baz</p>
''',
  r'''Foo
bar

---

baz
''': r'''<p>Foo
bar</p>
<hr />
<p>baz</p>
''',
  r'''Foo
bar
* * *
baz
''': r'''<p>Foo
bar</p>
<hr />
<p>baz</p>
''',
  r'''Foo
bar
\---
baz
''': r'''<p>Foo
bar
---
baz</p>
''',
  r'''    a simple
      indented code block
''': r'''<pre><code>a simple
  indented code block
</code></pre>
''',
  r'''  - foo

    bar
''': r'''<ul>
<li>
<p>foo</p>
<p>bar</p>
</li>
</ul>
''',
  r'''1.  foo

    - bar
''': r'''<ol>
<li>
<p>foo</p>
<ul>
<li>bar</li>
</ul>
</li>
</ol>
''',
  r'''    <a/>
    *hi*

    - one
''': r'''<pre><code>&lt;a/&gt;
*hi*

- one
</code></pre>
''',
  r'''    chunk1

    chunk2
  
 
 
    chunk3
''': r'''<pre><code>chunk1

chunk2



chunk3
</code></pre>
''',
  r'''    chunk1
      
      chunk2
''': r'''<pre><code>chunk1
  
  chunk2
</code></pre>
''',
  r'''Foo
    bar

''': r'''<p>Foo
bar</p>
''',
  r'''    foo
bar
''': r'''<pre><code>foo
</code></pre>
<p>bar</p>
''',
  r'''# Heading
    foo
Heading
------
    foo
----
''': r'''<h1>Heading</h1>
<pre><code>foo
</code></pre>
<h2>Heading</h2>
<pre><code>foo
</code></pre>
<hr />
''',
  r'''        foo
    bar
''': r'''<pre><code>    foo
bar
</code></pre>
''',
  r'''
    
    foo
    

''': r'''<pre><code>foo
</code></pre>
''',
  r'''    foo  
''': r'''<pre><code>foo  
</code></pre>
''',
  r'''```
<
 >
```
''': r'''<pre><code>&lt;
 &gt;
</code></pre>
''',
  r'''~~~
<
 >
~~~
''': r'''<pre><code>&lt;
 &gt;
</code></pre>
''',
  r'''```
aaa
~~~
```
''': r'''<pre><code>aaa
~~~
</code></pre>
''',
  r'''~~~
aaa
```
~~~
''': r'''<pre><code>aaa
```
</code></pre>
''',
  r'''````
aaa
```
``````
''': r'''<pre><code>aaa
```
</code></pre>
''',
  r'''~~~~
aaa
~~~
~~~~
''': r'''<pre><code>aaa
~~~
</code></pre>
''',
  r'''```
''': r'''<pre><code></code></pre>
''',
  r'''`````

```
aaa
''': r'''<pre><code>
```
aaa
</code></pre>
''',
  r'''> ```
> aaa

bbb
''': r'''<blockquote>
<pre><code>aaa
</code></pre>
</blockquote>
<p>bbb</p>
''',
  r'''```

  
```
''': r'''<pre><code>
  
</code></pre>
''',
  r'''```
```
''': r'''<pre><code></code></pre>
''',
  r''' ```
 aaa
aaa
```
''': r'''<pre><code>aaa
aaa
</code></pre>
''',
  r'''  ```
aaa
  aaa
aaa
  ```
''': r'''<pre><code>aaa
aaa
aaa
</code></pre>
''',
  r'''   ```
   aaa
    aaa
  aaa
   ```
''': r'''<pre><code>aaa
 aaa
aaa
</code></pre>
''',
  r'''    ```
    aaa
    ```
''': r'''<pre><code>```
aaa
```
</code></pre>
''',
  r'''```
aaa
  ```
''': r'''<pre><code>aaa
</code></pre>
''',
  r'''   ```
aaa
  ```
''': r'''<pre><code>aaa
</code></pre>
''',
  r'''```
aaa
    ```
''': r'''<pre><code>aaa
    ```
</code></pre>
''',
  r'''``` ```
aaa
''': r'''<p><code></code>
aaa</p>
''',
  r'''~~~~~~
aaa
~~~ ~~
''': r'''<pre><code>aaa
~~~ ~~
</code></pre>
''',
  r'''foo
```
bar
```
baz
''': r'''<p>foo</p>
<pre><code>bar
</code></pre>
<p>baz</p>
''',
  r'''foo
---
~~~
bar
~~~
# baz
''': r'''<h2>foo</h2>
<pre><code>bar
</code></pre>
<h1>baz</h1>
''',
  r'''```ruby
def foo(x)
  return 3
end
```
''': r'''<pre><code class="language-ruby">def foo(x)
  return 3
end
</code></pre>
''',
  r'''~~~~    ruby startline=3 $%@#$
def foo(x)
  return 3
end
~~~~~~~
''': r'''<pre><code class="language-ruby">def foo(x)
  return 3
end
</code></pre>
''',
  r'''````;
````
''': r'''<pre><code class="language-;"></code></pre>
''',
  r'''``` aa ```
foo
''': r'''<p><code>aa</code>
foo</p>
''',
  r'''```
``` aaa
```
''': r'''<pre><code>``` aaa
</code></pre>
''',
  r'''<table>
  <tr>
    <td>
           hi
    </td>
  </tr>
</table>

okay.
''': r'''<table>
  <tr>
    <td>
           hi
    </td>
  </tr>
</table>
<p>okay.</p>
''',
  r''' <div>
  *hello*
         <foo><a>
''': r''' <div>
  *hello*
         <foo><a>
''',
  r'''</div>
*foo*
''': r'''</div>
*foo*
''',
  r'''<DIV CLASS="foo">

*Markdown*

</DIV>
''': r'''<DIV CLASS="foo">
<p><em>Markdown</em></p>
</DIV>
''',
  r'''<div id="foo"
  class="bar">
</div>
''': r'''<div id="foo"
  class="bar">
</div>
''',
  r'''<div id="foo" class="bar
  baz">
</div>
''': r'''<div id="foo" class="bar
  baz">
</div>
''',
  r'''<div>
*foo*

*bar*
''': r'''<div>
*foo*
<p><em>bar</em></p>
''',
  r'''<div id="foo"
*hi*
''': r'''<div id="foo"
*hi*
''',
  r'''<div class
foo
''': r'''<div class
foo
''',
  r'''<div *???-&&&-<---
*foo*
''': r'''<div *???-&&&-<---
*foo*
''',
  r'''<div><a href="bar">*foo*</a></div>
''': r'''<div><a href="bar">*foo*</a></div>
''',
  r'''<table><tr><td>
foo
</td></tr></table>
''': r'''<table><tr><td>
foo
</td></tr></table>
''',
  r'''<div></div>
``` c
int x = 33;
```
''': r'''<div></div>
``` c
int x = 33;
```
''',
  r'''<a href="foo">
*bar*
</a>
''': r'''<a href="foo">
*bar*
</a>
''',
  r'''<Warning>
*bar*
</Warning>
''': r'''<Warning>
*bar*
</Warning>
''',
  r'''<i class="foo">
*bar*
</i>
''': r'''<i class="foo">
*bar*
</i>
''',
  r'''</ins>
*bar*
''': r'''</ins>
*bar*
''',
  r'''<del>
*foo*
</del>
''': r'''<del>
*foo*
</del>
''',
  r'''<del>

*foo*

</del>
''': r'''<del>
<p><em>foo</em></p>
</del>
''',
  r'''<del>*foo*</del>
''': r'''<p><del><em>foo</em></del></p>
''',
  r'''<pre language="haskell"><code>
import Text.HTML.TagSoup

main :: IO ()
main = print $ parseTags tags
</code></pre>
okay
''': r'''<pre language="haskell"><code>
import Text.HTML.TagSoup

main :: IO ()
main = print $ parseTags tags
</code></pre>
<p>okay</p>
''',
  r'''<script type="text/javascript">
// JavaScript example

document.getElementById("demo").innerHTML = "Hello JavaScript!";
</script>
okay
''': r'''<script type="text/javascript">
// JavaScript example

document.getElementById("demo").innerHTML = "Hello JavaScript!";
</script>
<p>okay</p>
''',
  r'''<style
  type="text/css">
h1 {color:red;}

p {color:blue;}
</style>
okay
''': r'''<style
  type="text/css">
h1 {color:red;}

p {color:blue;}
</style>
<p>okay</p>
''',
  r'''<style
  type="text/css">

foo
''': r'''<style
  type="text/css">

foo
''',
  r'''> <div>
> foo

bar
''': r'''<blockquote>
<div>
foo
</blockquote>
<p>bar</p>
''',
  r'''- <div>
- foo
''': r'''<ul>
<li>
<div>
</li>
<li>foo</li>
</ul>
''',
  r'''<style>p{color:red;}</style>
*foo*
''': r'''<style>p{color:red;}</style>
<p><em>foo</em></p>
''',
  r'''<!-- foo -->*bar*
*baz*
''': r'''<!-- foo -->*bar*
<p><em>baz</em></p>
''',
  r'''<script>
foo
</script>1. *bar*
''': r'''<script>
foo
</script>1. *bar*
''',
  r'''<!-- Foo

bar
   baz -->
okay
''': r'''<!-- Foo

bar
   baz -->
<p>okay</p>
''',
  r'''<?php

  echo '>';

?>
okay
''': r'''<?php

  echo '>';

?>
<p>okay</p>
''',
  r'''<!DOCTYPE html>
''': r'''<!DOCTYPE html>
''',
  r'''<![CDATA[
function matchwo(a,b)
{
  if (a < b && a < 0) then {
    return 1;

  } else {

    return 0;
  }
}
]]>
okay
''': r'''<![CDATA[
function matchwo(a,b)
{
  if (a < b && a < 0) then {
    return 1;

  } else {

    return 0;
  }
}
]]>
<p>okay</p>
''',
  r'''  <!-- foo -->

    <!-- foo -->
''': r'''  <!-- foo -->
<pre><code>&lt;!-- foo --&gt;
</code></pre>
''',
  r'''  <div>

    <div>
''': r'''  <div>
<pre><code>&lt;div&gt;
</code></pre>
''',
  r'''Foo
<div>
bar
</div>
''': r'''<p>Foo</p>
<div>
bar
</div>
''',
  r'''<div>
bar
</div>
*foo*
''': r'''<div>
bar
</div>
*foo*
''',
  r'''Foo
<a href="bar">
baz
''': r'''<p>Foo
<a href="bar">
baz</p>
''',
  r'''<div>

*Emphasized* text.

</div>
''': r'''<div>
<p><em>Emphasized</em> text.</p>
</div>
''',
  r'''<div>
*Emphasized* text.
</div>
''': r'''<div>
*Emphasized* text.
</div>
''',
  r'''<table>

<tr>

<td>
Hi
</td>

</tr>

</table>
''': r'''<table>
<tr>
<td>
Hi
</td>
</tr>
</table>
''',
  r'''<table>

  <tr>

    <td>
      Hi
    </td>

  </tr>

</table>
''': r'''<table>
  <tr>
<pre><code>&lt;td&gt;
  Hi
&lt;/td&gt;
</code></pre>
  </tr>
</table>
''',
  r'''[foo]: /url "title"

[foo]
''': r'''<p><a href="/url" title="title">foo</a></p>
''',
  r'''   [foo]: 
      /url  
           'the title'  

[foo]
''': r'''<p><a href="/url" title="the title">foo</a></p>
''',
  r'''[Foo*bar\]]:my_(url) 'title (with parens)'

[Foo*bar\]]
''': r'''<p><a href="my_(url)" title="title (with parens)">Foo*bar]</a></p>
''',
  r'''[Foo bar]:
<my%20url>
'title'

[Foo bar]
''': r'''<p><a href="my%20url" title="title">Foo bar</a></p>
''',
  r'''[foo]: /url '
title
line1
line2
'

[foo]
''': r'''<p><a href="/url" title="
title
line1
line2
">foo</a></p>
''',
  r'''[foo]: /url 'title

with blank line'

[foo]
''': r'''<p>[foo]: /url 'title</p>
<p>with blank line'</p>
<p>[foo]</p>
''',
  r'''[foo]:
/url

[foo]
''': r'''<p><a href="/url">foo</a></p>
''',
  r'''[foo]:

[foo]
''': r'''<p>[foo]:</p>
<p>[foo]</p>
''',
  r'''[foo]: /url\bar\*baz "foo\"bar\baz"

[foo]
''': r'''<p><a href="/url%5Cbar*baz" title="foo&quot;bar\baz">foo</a></p>
''',
  r'''[foo]

[foo]: url
''': r'''<p><a href="url">foo</a></p>
''',
  r'''[foo]

[foo]: first
[foo]: second
''': r'''<p><a href="first">foo</a></p>
''',
  r'''[FOO]: /url

[Foo]
''': r'''<p><a href="/url">Foo</a></p>
''',
  r'''[ΑΓΩ]: /φου

[αγω]
''': r'''<p><a href="/%CF%86%CE%BF%CF%85">αγω</a></p>
''',
  r'''[foo]: /url
''': r'''''',
  r'''[
foo
]: /url
bar
''': r'''<p>bar</p>
''',
  r'''[foo]: /url "title" ok
''': r'''<p>[foo]: /url &quot;title&quot; ok</p>
''',
  r'''[foo]: /url
"title" ok
''': r'''<p>&quot;title&quot; ok</p>
''',
  r'''    [foo]: /url "title"

[foo]
''': r'''<pre><code>[foo]: /url &quot;title&quot;
</code></pre>
<p>[foo]</p>
''',
  r'''```
[foo]: /url
```

[foo]
''': r'''<pre><code>[foo]: /url
</code></pre>
<p>[foo]</p>
''',
  r'''Foo
[bar]: /baz

[bar]
''': r'''<p>Foo
[bar]: /baz</p>
<p>[bar]</p>
''',
  r'''# [Foo]
[foo]: /url
> bar
''': r'''<h1><a href="/url">Foo</a></h1>
<blockquote>
<p>bar</p>
</blockquote>
''',
  r'''[foo]: /foo-url "foo"
[bar]: /bar-url
  "bar"
[baz]: /baz-url

[foo],
[bar],
[baz]
''': r'''<p><a href="/foo-url" title="foo">foo</a>,
<a href="/bar-url" title="bar">bar</a>,
<a href="/baz-url">baz</a></p>
''',
  r'''[foo]

> [foo]: /url
''': r'''<p><a href="/url">foo</a></p>
<blockquote>
</blockquote>
''',
  r'''aaa

bbb
''': r'''<p>aaa</p>
<p>bbb</p>
''',
  r'''aaa
bbb

ccc
ddd
''': r'''<p>aaa
bbb</p>
<p>ccc
ddd</p>
''',
  r'''aaa


bbb
''': r'''<p>aaa</p>
<p>bbb</p>
''',
  r'''  aaa
 bbb
''': r'''<p>aaa
bbb</p>
''',
  r'''aaa
             bbb
                                       ccc
''': r'''<p>aaa
bbb
ccc</p>
''',
  r'''   aaa
bbb
''': r'''<p>aaa
bbb</p>
''',
  r'''    aaa
bbb
''': r'''<pre><code>aaa
</code></pre>
<p>bbb</p>
''',
  r'''aaa     
bbb     
''': r'''<p>aaa<br />
bbb</p>
''',
  r'''  

aaa
  

# aaa

  
''': r'''<p>aaa</p>
<h1>aaa</h1>
''',
  r'''> # Foo
> bar
> baz
''': r'''<blockquote>
<h1>Foo</h1>
<p>bar
baz</p>
</blockquote>
''',
  r'''># Foo
>bar
> baz
''': r'''<blockquote>
<h1>Foo</h1>
<p>bar
baz</p>
</blockquote>
''',
  r'''   > # Foo
   > bar
 > baz
''': r'''<blockquote>
<h1>Foo</h1>
<p>bar
baz</p>
</blockquote>
''',
  r'''    > # Foo
    > bar
    > baz
''': r'''<pre><code>&gt; # Foo
&gt; bar
&gt; baz
</code></pre>
''',
  r'''> # Foo
> bar
baz
''': r'''<blockquote>
<h1>Foo</h1>
<p>bar
baz</p>
</blockquote>
''',
  r'''> bar
baz
> foo
''': r'''<blockquote>
<p>bar
baz
foo</p>
</blockquote>
''',
  r'''> foo
---
''': r'''<blockquote>
<p>foo</p>
</blockquote>
<hr />
''',
  r'''> - foo
- bar
''': r'''<blockquote>
<ul>
<li>foo</li>
</ul>
</blockquote>
<ul>
<li>bar</li>
</ul>
''',
  r'''>     foo
    bar
''': r'''<blockquote>
<pre><code>foo
</code></pre>
</blockquote>
<pre><code>bar
</code></pre>
''',
  r'''> ```
foo
```
''': r'''<blockquote>
<pre><code></code></pre>
</blockquote>
<p>foo</p>
<pre><code></code></pre>
''',
  r'''> foo
    - bar
''': r'''<blockquote>
<p>foo
- bar</p>
</blockquote>
''',
  r'''>
''': r'''<blockquote>
</blockquote>
''',
  r'''>
>  
> 
''': r'''<blockquote>
</blockquote>
''',
  r'''>
> foo
>  
''': r'''<blockquote>
<p>foo</p>
</blockquote>
''',
  r'''> foo

> bar
''': r'''<blockquote>
<p>foo</p>
</blockquote>
<blockquote>
<p>bar</p>
</blockquote>
''',
  r'''> foo
> bar
''': r'''<blockquote>
<p>foo
bar</p>
</blockquote>
''',
  r'''> foo
>
> bar
''': r'''<blockquote>
<p>foo</p>
<p>bar</p>
</blockquote>
''',
  r'''foo
> bar
''': r'''<p>foo</p>
<blockquote>
<p>bar</p>
</blockquote>
''',
  r'''> aaa
***
> bbb
''': r'''<blockquote>
<p>aaa</p>
</blockquote>
<hr />
<blockquote>
<p>bbb</p>
</blockquote>
''',
  r'''> bar
baz
''': r'''<blockquote>
<p>bar
baz</p>
</blockquote>
''',
  r'''> bar

baz
''': r'''<blockquote>
<p>bar</p>
</blockquote>
<p>baz</p>
''',
  r'''> bar
>
baz
''': r'''<blockquote>
<p>bar</p>
</blockquote>
<p>baz</p>
''',
  r'''> > > foo
bar
''': r'''<blockquote>
<blockquote>
<blockquote>
<p>foo
bar</p>
</blockquote>
</blockquote>
</blockquote>
''',
  r'''>>> foo
> bar
>>baz
''': r'''<blockquote>
<blockquote>
<blockquote>
<p>foo
bar
baz</p>
</blockquote>
</blockquote>
</blockquote>
''',
  r'''>     code

>    not code
''': r'''<blockquote>
<pre><code>code
</code></pre>
</blockquote>
<blockquote>
<p>not code</p>
</blockquote>
''',
  r'''A paragraph
with two lines.

    indented code

> A block quote.
''': r'''<p>A paragraph
with two lines.</p>
<pre><code>indented code
</code></pre>
<blockquote>
<p>A block quote.</p>
</blockquote>
''',
  r'''1.  A paragraph
    with two lines.

        indented code

    > A block quote.
''': r'''<ol>
<li>
<p>A paragraph
with two lines.</p>
<pre><code>indented code
</code></pre>
<blockquote>
<p>A block quote.</p>
</blockquote>
</li>
</ol>
''',
  r'''- one

 two
''': r'''<ul>
<li>one</li>
</ul>
<p>two</p>
''',
  r'''- one

  two
''': r'''<ul>
<li>
<p>one</p>
<p>two</p>
</li>
</ul>
''',
  r''' -    one

     two
''': r'''<ul>
<li>one</li>
</ul>
<pre><code> two
</code></pre>
''',
  r''' -    one

      two
''': r'''<ul>
<li>
<p>one</p>
<p>two</p>
</li>
</ul>
''',
  r'''   > > 1.  one
>>
>>     two
''': r'''<blockquote>
<blockquote>
<ol>
<li>
<p>one</p>
<p>two</p>
</li>
</ol>
</blockquote>
</blockquote>
''',
  r'''>>- one
>>
  >  > two
''': r'''<blockquote>
<blockquote>
<ul>
<li>one</li>
</ul>
<p>two</p>
</blockquote>
</blockquote>
''',
  r'''-one

2.two
''': r'''<p>-one</p>
<p>2.two</p>
''',
  r'''- foo


  bar
''': r'''<ul>
<li>
<p>foo</p>
<p>bar</p>
</li>
</ul>
''',
  r'''1.  foo

    ```
    bar
    ```

    baz

    > bam
''': r'''<ol>
<li>
<p>foo</p>
<pre><code>bar
</code></pre>
<p>baz</p>
<blockquote>
<p>bam</p>
</blockquote>
</li>
</ol>
''',
  r'''- Foo

      bar


      baz
''': r'''<ul>
<li>
<p>Foo</p>
<pre><code>bar


baz
</code></pre>
</li>
</ul>
''',
  r'''123456789. ok
''': r'''<ol start="123456789">
<li>ok</li>
</ol>
''',
  r'''1234567890. not ok
''': r'''<p>1234567890. not ok</p>
''',
  r'''0. ok
''': r'''<ol start="0">
<li>ok</li>
</ol>
''',
  r'''003. ok
''': r'''<ol start="3">
<li>ok</li>
</ol>
''',
  r'''-1. not ok
''': r'''<p>-1. not ok</p>
''',
  r'''- foo

      bar
''': r'''<ul>
<li>
<p>foo</p>
<pre><code>bar
</code></pre>
</li>
</ul>
''',
  r'''  10.  foo

           bar
''': r'''<ol start="10">
<li>
<p>foo</p>
<pre><code>bar
</code></pre>
</li>
</ol>
''',
  r'''    indented code

paragraph

    more code
''': r'''<pre><code>indented code
</code></pre>
<p>paragraph</p>
<pre><code>more code
</code></pre>
''',
  r'''1.     indented code

   paragraph

       more code
''': r'''<ol>
<li>
<pre><code>indented code
</code></pre>
<p>paragraph</p>
<pre><code>more code
</code></pre>
</li>
</ol>
''',
  r'''1.      indented code

   paragraph

       more code
''': r'''<ol>
<li>
<pre><code> indented code
</code></pre>
<p>paragraph</p>
<pre><code>more code
</code></pre>
</li>
</ol>
''',
  r'''   foo

bar
''': r'''<p>foo</p>
<p>bar</p>
''',
  r'''-    foo

  bar
''': r'''<ul>
<li>foo</li>
</ul>
<p>bar</p>
''',
  r'''-  foo

   bar
''': r'''<ul>
<li>
<p>foo</p>
<p>bar</p>
</li>
</ul>
''',
  r'''-
  foo
-
  ```
  bar
  ```
-
      baz
''': r'''<ul>
<li>foo</li>
<li>
<pre><code>bar
</code></pre>
</li>
<li>
<pre><code>baz
</code></pre>
</li>
</ul>
''',
  r'''-   
  foo
''': r'''<ul>
<li>foo</li>
</ul>
''',
  r'''-

  foo
''': r'''<ul>
<li></li>
</ul>
<p>foo</p>
''',
  r'''- foo
-
- bar
''': r'''<ul>
<li>foo</li>
<li></li>
<li>bar</li>
</ul>
''',
  r'''- foo
-   
- bar
''': r'''<ul>
<li>foo</li>
<li></li>
<li>bar</li>
</ul>
''',
  r'''1. foo
2.
3. bar
''': r'''<ol>
<li>foo</li>
<li></li>
<li>bar</li>
</ol>
''',
  r'''*
''': r'''<ul>
<li></li>
</ul>
''',
  r'''foo
*

foo
1.
''': r'''<p>foo
*</p>
<p>foo
1.</p>
''',
  r''' 1.  A paragraph
     with two lines.

         indented code

     > A block quote.
''': r'''<ol>
<li>
<p>A paragraph
with two lines.</p>
<pre><code>indented code
</code></pre>
<blockquote>
<p>A block quote.</p>
</blockquote>
</li>
</ol>
''',
  r'''  1.  A paragraph
      with two lines.

          indented code

      > A block quote.
''': r'''<ol>
<li>
<p>A paragraph
with two lines.</p>
<pre><code>indented code
</code></pre>
<blockquote>
<p>A block quote.</p>
</blockquote>
</li>
</ol>
''',
  r'''   1.  A paragraph
       with two lines.

           indented code

       > A block quote.
''': r'''<ol>
<li>
<p>A paragraph
with two lines.</p>
<pre><code>indented code
</code></pre>
<blockquote>
<p>A block quote.</p>
</blockquote>
</li>
</ol>
''',
  r'''    1.  A paragraph
        with two lines.

            indented code

        > A block quote.
''': r'''<pre><code>1.  A paragraph
    with two lines.

        indented code

    &gt; A block quote.
</code></pre>
''',
  r'''  1.  A paragraph
with two lines.

          indented code

      > A block quote.
''': r'''<ol>
<li>
<p>A paragraph
with two lines.</p>
<pre><code>indented code
</code></pre>
<blockquote>
<p>A block quote.</p>
</blockquote>
</li>
</ol>
''',
  r'''  1.  A paragraph
    with two lines.
''': r'''<ol>
<li>A paragraph
with two lines.</li>
</ol>
''',
  r'''> 1. > Blockquote
continued here.
''': r'''<blockquote>
<ol>
<li>
<blockquote>
<p>Blockquote
continued here.</p>
</blockquote>
</li>
</ol>
</blockquote>
''',
  r'''> 1. > Blockquote
> continued here.
''': r'''<blockquote>
<ol>
<li>
<blockquote>
<p>Blockquote
continued here.</p>
</blockquote>
</li>
</ol>
</blockquote>
''',
  r'''- foo
  - bar
    - baz
      - boo
''': r'''<ul>
<li>foo
<ul>
<li>bar
<ul>
<li>baz
<ul>
<li>boo</li>
</ul>
</li>
</ul>
</li>
</ul>
</li>
</ul>
''',
  r'''- foo
 - bar
  - baz
   - boo
''': r'''<ul>
<li>foo</li>
<li>bar</li>
<li>baz</li>
<li>boo</li>
</ul>
''',
  r'''10) foo
    - bar
''': r'''<ol start="10">
<li>foo
<ul>
<li>bar</li>
</ul>
</li>
</ol>
''',
  r'''10) foo
   - bar
''': r'''<ol start="10">
<li>foo</li>
</ol>
<ul>
<li>bar</li>
</ul>
''',
  r'''- - foo
''': r'''<ul>
<li>
<ul>
<li>foo</li>
</ul>
</li>
</ul>
''',
  r'''1. - 2. foo
''': r'''<ol>
<li>
<ul>
<li>
<ol start="2">
<li>foo</li>
</ol>
</li>
</ul>
</li>
</ol>
''',
  r'''- # Foo
- Bar
  ---
  baz
''': r'''<ul>
<li>
<h1>Foo</h1>
</li>
<li>
<h2>Bar</h2>
baz</li>
</ul>
''',
  r'''- foo
- bar
+ baz
''': r'''<ul>
<li>foo</li>
<li>bar</li>
</ul>
<ul>
<li>baz</li>
</ul>
''',
  r'''1. foo
2. bar
3) baz
''': r'''<ol>
<li>foo</li>
<li>bar</li>
</ol>
<ol start="3">
<li>baz</li>
</ol>
''',
  r'''Foo
- bar
- baz
''': r'''<p>Foo</p>
<ul>
<li>bar</li>
<li>baz</li>
</ul>
''',
  r'''The number of windows in my house is
14.  The number of doors is 6.
''': r'''<p>The number of windows in my house is
14.  The number of doors is 6.</p>
''',
  r'''The number of windows in my house is
1.  The number of doors is 6.
''': r'''<p>The number of windows in my house is</p>
<ol>
<li>The number of doors is 6.</li>
</ol>
''',
  r'''- foo

- bar


- baz
''': r'''<ul>
<li>
<p>foo</p>
</li>
<li>
<p>bar</p>
</li>
<li>
<p>baz</p>
</li>
</ul>
''',
  r'''- foo
  - bar
    - baz


      bim
''': r'''<ul>
<li>foo
<ul>
<li>bar
<ul>
<li>
<p>baz</p>
<p>bim</p>
</li>
</ul>
</li>
</ul>
</li>
</ul>
''',
  r'''- foo
- bar

<!-- -->

- baz
- bim
''': r'''<ul>
<li>foo</li>
<li>bar</li>
</ul>
<!-- -->
<ul>
<li>baz</li>
<li>bim</li>
</ul>
''',
  r'''-   foo

    notcode

-   foo

<!-- -->

    code
''': r'''<ul>
<li>
<p>foo</p>
<p>notcode</p>
</li>
<li>
<p>foo</p>
</li>
</ul>
<!-- -->
<pre><code>code
</code></pre>
''',
  r'''- a
 - b
  - c
   - d
    - e
   - f
  - g
 - h
- i
''': r'''<ul>
<li>a</li>
<li>b</li>
<li>c</li>
<li>d</li>
<li>e</li>
<li>f</li>
<li>g</li>
<li>h</li>
<li>i</li>
</ul>
''',
  r'''1. a

  2. b

    3. c
''': r'''<ol>
<li>
<p>a</p>
</li>
<li>
<p>b</p>
</li>
<li>
<p>c</p>
</li>
</ol>
''',
  r'''- a
- b

- c
''': r'''<ul>
<li>
<p>a</p>
</li>
<li>
<p>b</p>
</li>
<li>
<p>c</p>
</li>
</ul>
''',
  r'''* a
*

* c
''': r'''<ul>
<li>
<p>a</p>
</li>
<li></li>
<li>
<p>c</p>
</li>
</ul>
''',
  r'''- a
- b

  c
- d
''': r'''<ul>
<li>
<p>a</p>
</li>
<li>
<p>b</p>
<p>c</p>
</li>
<li>
<p>d</p>
</li>
</ul>
''',
  r'''- a
- b

  [ref]: /url
- d
''': r'''<ul>
<li>
<p>a</p>
</li>
<li>
<p>b</p>
</li>
<li>
<p>d</p>
</li>
</ul>
''',
  r'''- a
- ```
  b


  ```
- c
''': r'''<ul>
<li>a</li>
<li>
<pre><code>b


</code></pre>
</li>
<li>c</li>
</ul>
''',
  r'''- a
  - b

    c
- d
''': r'''<ul>
<li>a
<ul>
<li>
<p>b</p>
<p>c</p>
</li>
</ul>
</li>
<li>d</li>
</ul>
''',
  r'''* a
  > b
  >
* c
''': r'''<ul>
<li>a
<blockquote>
<p>b</p>
</blockquote>
</li>
<li>c</li>
</ul>
''',
  r'''- a
  > b
  ```
  c
  ```
- d
''': r'''<ul>
<li>a
<blockquote>
<p>b</p>
</blockquote>
<pre><code>c
</code></pre>
</li>
<li>d</li>
</ul>
''',
  r'''- a
''': r'''<ul>
<li>a</li>
</ul>
''',
  r'''- a
  - b
''': r'''<ul>
<li>a
<ul>
<li>b</li>
</ul>
</li>
</ul>
''',
  r'''1. ```
   foo
   ```

   bar
''': r'''<ol>
<li>
<pre><code>foo
</code></pre>
<p>bar</p>
</li>
</ol>
''',
  r'''* foo
  * bar

  baz
''': r'''<ul>
<li>
<p>foo</p>
<ul>
<li>bar</li>
</ul>
<p>baz</p>
</li>
</ul>
''',
  r'''- a
  - b
  - c

- d
  - e
  - f
''': r'''<ul>
<li>
<p>a</p>
<ul>
<li>b</li>
<li>c</li>
</ul>
</li>
<li>
<p>d</p>
<ul>
<li>e</li>
<li>f</li>
</ul>
</li>
</ul>
''',
  r'''`hi`lo`
''': r'''<p><code>hi</code>lo`</p>
''',
  r'''\!\"\#\$\%\&\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\\\]\^\_\`\{\|\}\~
''': r'''<p>!&quot;#$%&amp;'()*+,-./:;&lt;=&gt;?@[\]^_`{|}~</p>
''',
  r'''\→\A\a\ \3\φ\«
''': r'''<p>\→\A\a\ \3\φ\«</p>
''',
  r'''\*not emphasized*
\<br/> not a tag
\[not a link](/foo)
\`not code`
1\. not a list
\* not a list
\# not a heading
\[foo]: /url "not a reference"
''': r'''<p>*not emphasized*
&lt;br/&gt; not a tag
[not a link](/foo)
`not code`
1. not a list
* not a list
# not a heading
[foo]: /url &quot;not a reference&quot;</p>
''',
  r'''\\*emphasis*
''': r'''<p>\<em>emphasis</em></p>
''',
  r'''foo\
bar
''': r'''<p>foo<br />
bar</p>
''',
  r'''`` \[\` ``
''': r'''<p><code>\[\`</code></p>
''',
  r'''    \[\]
''': r'''<pre><code>\[\]
</code></pre>
''',
  r'''~~~
\[\]
~~~
''': r'''<pre><code>\[\]
</code></pre>
''',
  r'''<http://example.com?find=\*>
''': r'''<p><a href="http://example.com?find=%5C*">http://example.com?find=\*</a></p>
''',
  r'''<a href="/bar\/)">
''': r'''<a href="/bar\/)">
''',
  r'''[foo](/bar\* "ti\*tle")
''': r'''<p><a href="/bar*" title="ti*tle">foo</a></p>
''',
  r'''[foo]

[foo]: /bar\* "ti\*tle"
''': r'''<p><a href="/bar*" title="ti*tle">foo</a></p>
''',
  r'''``` foo\+bar
foo
```
''': r'''<pre><code class="language-foo+bar">foo
</code></pre>
''',
  r'''&nbsp; &amp; &copy; &AElig; &Dcaron;
&frac34; &HilbertSpace; &DifferentialD;
&ClockwiseContourIntegral; &ngE;
''': r'''<p>  &amp; © Æ Ď
¾ ℋ ⅆ
∲ ≧̸</p>
''',
  r'''&#35; &#1234; &#992; &#98765432; &#0;
''': r'''<p># Ӓ Ϡ � �</p>
''',
  r'''&#X22; &#XD06; &#xcab;
''': r'''<p>&quot; ആ ಫ</p>
''',
  r'''&nbsp &x; &#; &#x;
&ThisIsNotDefined; &hi?;
''': r'''<p>&amp;nbsp &amp;x; &amp;#; &amp;#x;
&amp;ThisIsNotDefined; &amp;hi?;</p>
''',
  r'''&copy
''': r'''<p>&amp;copy</p>
''',
  r'''&MadeUpEntity;
''': r'''<p>&amp;MadeUpEntity;</p>
''',
  r'''<a href="&ouml;&ouml;.html">
''': r'''<a href="&ouml;&ouml;.html">
''',
  r'''[foo](/f&ouml;&ouml; "f&ouml;&ouml;")
''': r'''<p><a href="/f%C3%B6%C3%B6" title="föö">foo</a></p>
''',
  r'''[foo]

[foo]: /f&ouml;&ouml; "f&ouml;&ouml;"
''': r'''<p><a href="/f%C3%B6%C3%B6" title="föö">foo</a></p>
''',
  r'''``` f&ouml;&ouml;
foo
```
''': r'''<pre><code class="language-föö">foo
</code></pre>
''',
  r'''`f&ouml;&ouml;`
''': r'''<p><code>f&amp;ouml;&amp;ouml;</code></p>
''',
  r'''    f&ouml;f&ouml;
''': r'''<pre><code>f&amp;ouml;f&amp;ouml;
</code></pre>
''',
  r'''`foo`
''': r'''<p><code>foo</code></p>
''',
  r'''`` foo ` bar  ``
''': r'''<p><code>foo ` bar</code></p>
''',
  r'''` `` `
''': r'''<p><code>``</code></p>
''',
  r'''``
foo
``
''': r'''<p><code>foo</code></p>
''',
  r'''`foo   bar
  baz`
''': r'''<p><code>foo bar baz</code></p>
''',
  r'''`a  b`
''': r'''<p><code>a  b</code></p>
''',
  r'''`foo `` bar`
''': r'''<p><code>foo `` bar</code></p>
''',
  r'''`foo\`bar`
''': r'''<p><code>foo\</code>bar`</p>
''',
  r'''*foo`*`
''': r'''<p>*foo<code>*</code></p>
''',
  r'''[not a `link](/foo`)
''': r'''<p>[not a <code>link](/foo</code>)</p>
''',
  r'''`<a href="`">`
''': r'''<p><code>&lt;a href=&quot;</code>&quot;&gt;`</p>
''',
  r'''<a href="`">`
''': r'''<p><a href="`">`</p>
''',
  r'''`<http://foo.bar.`baz>`
''': r'''<p><code>&lt;http://foo.bar.</code>baz&gt;`</p>
''',
  r'''<http://foo.bar.`baz>`
''': r'''<p><a href="http://foo.bar.%60baz">http://foo.bar.`baz</a>`</p>
''',
  r'''```foo``
''': r'''<p>```foo``</p>
''',
  r'''`foo
''': r'''<p>`foo</p>
''',
  r'''*foo bar*
''': r'''<p><em>foo bar</em></p>
''',
  r'''a * foo bar*
''': r'''<p>a * foo bar*</p>
''',
  r'''a*"foo"*
''': r'''<p>a*&quot;foo&quot;*</p>
''',
  r'''* a *
''': r'''<p>* a *</p>
''',
  r'''foo*bar*
''': r'''<p>foo<em>bar</em></p>
''',
  r'''5*6*78
''': r'''<p>5<em>6</em>78</p>
''',
  r'''_foo bar_
''': r'''<p><em>foo bar</em></p>
''',
  r'''_ foo bar_
''': r'''<p>_ foo bar_</p>
''',
  r'''a_"foo"_
''': r'''<p>a_&quot;foo&quot;_</p>
''',
  r'''foo_bar_
''': r'''<p>foo_bar_</p>
''',
  r'''5_6_78
''': r'''<p>5_6_78</p>
''',
  r'''пристаням_стремятся_
''': r'''<p>пристаням_стремятся_</p>
''',
  r'''aa_"bb"_cc
''': r'''<p>aa_&quot;bb&quot;_cc</p>
''',
  r'''foo-_(bar)_
''': r'''<p>foo-<em>(bar)</em></p>
''',
  r'''_foo*
''': r'''<p>_foo*</p>
''',
  r'''*foo bar *
''': r'''<p>*foo bar *</p>
''',
  r'''*foo bar
*
''': r'''<p>*foo bar
*</p>
''',
  r'''*(*foo)
''': r'''<p>*(*foo)</p>
''',
  r'''*(*foo*)*
''': r'''<p><em>(<em>foo</em>)</em></p>
''',
  r'''*foo*bar
''': r'''<p><em>foo</em>bar</p>
''',
  r'''_foo bar _
''': r'''<p>_foo bar _</p>
''',
  r'''_(_foo)
''': r'''<p>_(_foo)</p>
''',
  r'''_(_foo_)_
''': r'''<p><em>(<em>foo</em>)</em></p>
''',
  r'''_foo_bar
''': r'''<p>_foo_bar</p>
''',
  r'''_пристаням_стремятся
''': r'''<p>_пристаням_стремятся</p>
''',
  r'''_foo_bar_baz_
''': r'''<p><em>foo_bar_baz</em></p>
''',
  r'''_(bar)_.
''': r'''<p><em>(bar)</em>.</p>
''',
  r'''**foo bar**
''': r'''<p><strong>foo bar</strong></p>
''',
  r'''** foo bar**
''': r'''<p>** foo bar**</p>
''',
  r'''a**"foo"**
''': r'''<p>a**&quot;foo&quot;**</p>
''',
  r'''foo**bar**
''': r'''<p>foo<strong>bar</strong></p>
''',
  r'''__foo bar__
''': r'''<p><strong>foo bar</strong></p>
''',
  r'''__ foo bar__
''': r'''<p>__ foo bar__</p>
''',
  r'''__
foo bar__
''': r'''<p>__
foo bar__</p>
''',
  r'''a__"foo"__
''': r'''<p>a__&quot;foo&quot;__</p>
''',
  r'''foo__bar__
''': r'''<p>foo__bar__</p>
''',
  r'''5__6__78
''': r'''<p>5__6__78</p>
''',
  r'''пристаням__стремятся__
''': r'''<p>пристаням__стремятся__</p>
''',
  r'''__foo, __bar__, baz__
''': r'''<p><strong>foo, <strong>bar</strong>, baz</strong></p>
''',
  r'''foo-__(bar)__
''': r'''<p>foo-<strong>(bar)</strong></p>
''',
  r'''**foo bar **
''': r'''<p>**foo bar **</p>
''',
  r'''**(**foo)
''': r'''<p>**(**foo)</p>
''',
  r'''*(**foo**)*
''': r'''<p><em>(<strong>foo</strong>)</em></p>
''',
  r'''**Gomphocarpus (*Gomphocarpus physocarpus*, syn.
*Asclepias physocarpa*)**
''': r'''<p><strong>Gomphocarpus (<em>Gomphocarpus physocarpus</em>, syn.
<em>Asclepias physocarpa</em>)</strong></p>
''',
  r'''**foo "*bar*" foo**
''': r'''<p><strong>foo &quot;<em>bar</em>&quot; foo</strong></p>
''',
  r'''**foo**bar
''': r'''<p><strong>foo</strong>bar</p>
''',
  r'''__foo bar __
''': r'''<p>__foo bar __</p>
''',
  r'''__(__foo)
''': r'''<p>__(__foo)</p>
''',
  r'''_(__foo__)_
''': r'''<p><em>(<strong>foo</strong>)</em></p>
''',
  r'''__foo__bar
''': r'''<p>__foo__bar</p>
''',
  r'''__пристаням__стремятся
''': r'''<p>__пристаням__стремятся</p>
''',
  r'''__foo__bar__baz__
''': r'''<p><strong>foo__bar__baz</strong></p>
''',
  r'''__(bar)__.
''': r'''<p><strong>(bar)</strong>.</p>
''',
  r'''*foo [bar](/url)*
''': r'''<p><em>foo <a href="/url">bar</a></em></p>
''',
  r'''*foo
bar*
''': r'''<p><em>foo
bar</em></p>
''',
  r'''_foo __bar__ baz_
''': r'''<p><em>foo <strong>bar</strong> baz</em></p>
''',
  r'''_foo _bar_ baz_
''': r'''<p><em>foo <em>bar</em> baz</em></p>
''',
  r'''__foo_ bar_
''': r'''<p><em><em>foo</em> bar</em></p>
''',
  r'''*foo *bar**
''': r'''<p><em>foo <em>bar</em></em></p>
''',
  r'''*foo **bar** baz*
''': r'''<p><em>foo <strong>bar</strong> baz</em></p>
''',
  r'''*foo**bar**baz*
''': r'''<p><em>foo<strong>bar</strong>baz</em></p>
''',
  r'''***foo** bar*
''': r'''<p><em><strong>foo</strong> bar</em></p>
''',
  r'''*foo **bar***
''': r'''<p><em>foo <strong>bar</strong></em></p>
''',
  r'''*foo**bar***
''': r'''<p><em>foo<strong>bar</strong></em></p>
''',
  r'''*foo **bar *baz* bim** bop*
''': r'''<p><em>foo <strong>bar <em>baz</em> bim</strong> bop</em></p>
''',
  r'''*foo [*bar*](/url)*
''': r'''<p><em>foo <a href="/url"><em>bar</em></a></em></p>
''',
  r'''** is not an empty emphasis
''': r'''<p>** is not an empty emphasis</p>
''',
  r'''**** is not an empty strong emphasis
''': r'''<p>**** is not an empty strong emphasis</p>
''',
  r'''**foo [bar](/url)**
''': r'''<p><strong>foo <a href="/url">bar</a></strong></p>
''',
  r'''**foo
bar**
''': r'''<p><strong>foo
bar</strong></p>
''',
  r'''__foo _bar_ baz__
''': r'''<p><strong>foo <em>bar</em> baz</strong></p>
''',
  r'''__foo __bar__ baz__
''': r'''<p><strong>foo <strong>bar</strong> baz</strong></p>
''',
  r'''____foo__ bar__
''': r'''<p><strong><strong>foo</strong> bar</strong></p>
''',
  r'''**foo **bar****
''': r'''<p><strong>foo <strong>bar</strong></strong></p>
''',
  r'''**foo *bar* baz**
''': r'''<p><strong>foo <em>bar</em> baz</strong></p>
''',
  r'''**foo*bar*baz**
''': r'''<p><strong>foo<em>bar</em>baz</strong></p>
''',
  r'''***foo* bar**
''': r'''<p><strong><em>foo</em> bar</strong></p>
''',
  r'''**foo *bar***
''': r'''<p><strong>foo <em>bar</em></strong></p>
''',
  r'''**foo *bar **baz**
bim* bop**
''': r'''<p><strong>foo <em>bar <strong>baz</strong>
bim</em> bop</strong></p>
''',
  r'''**foo [*bar*](/url)**
''': r'''<p><strong>foo <a href="/url"><em>bar</em></a></strong></p>
''',
  r'''__ is not an empty emphasis
''': r'''<p>__ is not an empty emphasis</p>
''',
  r'''____ is not an empty strong emphasis
''': r'''<p>____ is not an empty strong emphasis</p>
''',
  r'''foo ***
''': r'''<p>foo ***</p>
''',
  r'''foo *\**
''': r'''<p>foo <em>*</em></p>
''',
  r'''foo *_*
''': r'''<p>foo <em>_</em></p>
''',
  r'''foo *****
''': r'''<p>foo *****</p>
''',
  r'''foo **\***
''': r'''<p>foo <strong>*</strong></p>
''',
  r'''foo **_**
''': r'''<p>foo <strong>_</strong></p>
''',
  r'''**foo*
''': r'''<p>*<em>foo</em></p>
''',
  r'''*foo**
''': r'''<p><em>foo</em>*</p>
''',
  r'''***foo**
''': r'''<p>*<strong>foo</strong></p>
''',
  r'''****foo*
''': r'''<p>***<em>foo</em></p>
''',
  r'''**foo***
''': r'''<p><strong>foo</strong>*</p>
''',
  r'''*foo****
''': r'''<p><em>foo</em>***</p>
''',
  r'''foo ___
''': r'''<p>foo ___</p>
''',
  r'''foo _\__
''': r'''<p>foo <em>_</em></p>
''',
  r'''foo _*_
''': r'''<p>foo <em>*</em></p>
''',
  r'''foo _____
''': r'''<p>foo _____</p>
''',
  r'''foo __\___
''': r'''<p>foo <strong>_</strong></p>
''',
  r'''foo __*__
''': r'''<p>foo <strong>*</strong></p>
''',
  r'''__foo_
''': r'''<p>_<em>foo</em></p>
''',
  r'''_foo__
''': r'''<p><em>foo</em>_</p>
''',
  r'''___foo__
''': r'''<p>_<strong>foo</strong></p>
''',
  r'''____foo_
''': r'''<p>___<em>foo</em></p>
''',
  r'''__foo___
''': r'''<p><strong>foo</strong>_</p>
''',
  r'''_foo____
''': r'''<p><em>foo</em>___</p>
''',
  r'''**foo**
''': r'''<p><strong>foo</strong></p>
''',
  r'''*_foo_*
''': r'''<p><em><em>foo</em></em></p>
''',
  r'''__foo__
''': r'''<p><strong>foo</strong></p>
''',
  r'''_*foo*_
''': r'''<p><em><em>foo</em></em></p>
''',
  r'''****foo****
''': r'''<p><strong><strong>foo</strong></strong></p>
''',
  r'''____foo____
''': r'''<p><strong><strong>foo</strong></strong></p>
''',
  r'''******foo******
''': r'''<p><strong><strong><strong>foo</strong></strong></strong></p>
''',
  r'''***foo***
''': r'''<p><strong><em>foo</em></strong></p>
''',
  r'''_____foo_____
''': r'''<p><strong><strong><em>foo</em></strong></strong></p>
''',
  r'''*foo _bar* baz_
''': r'''<p><em>foo _bar</em> baz_</p>
''',
  r'''*foo __bar *baz bim__ bam*
''': r'''<p><em>foo <strong>bar *baz bim</strong> bam</em></p>
''',
  r'''**foo **bar baz**
''': r'''<p>**foo <strong>bar baz</strong></p>
''',
  r'''*foo *bar baz*
''': r'''<p>*foo <em>bar baz</em></p>
''',
  r'''*[bar*](/url)
''': r'''<p>*<a href="/url">bar*</a></p>
''',
  r'''_foo [bar_](/url)
''': r'''<p>_foo <a href="/url">bar_</a></p>
''',
  r'''*<img src="foo" title="*"/>
''': r'''<p>*<img src="foo" title="*"/></p>
''',
  r'''**<a href="**">
''': r'''<p>**<a href="**"></p>
''',
  r'''__<a href="__">
''': r'''<p>__<a href="__"></p>
''',
  r'''*a `*`*
''': r'''<p><em>a <code>*</code></em></p>
''',
  r'''_a `_`_
''': r'''<p><em>a <code>_</code></em></p>
''',
  r'''**a<http://foo.bar/?q=**>
''': r'''<p>**a<a href="http://foo.bar/?q=**">http://foo.bar/?q=**</a></p>
''',
  r'''__a<http://foo.bar/?q=__>
''': r'''<p>__a<a href="http://foo.bar/?q=__">http://foo.bar/?q=__</a></p>
''',
  r'''[link](/uri "title")
''': r'''<p><a href="/uri" title="title">link</a></p>
''',
  r'''[link](/uri)
''': r'''<p><a href="/uri">link</a></p>
''',
  r'''[link]()
''': r'''<p><a href="">link</a></p>
''',
  r'''[link](<>)
''': r'''<p><a href="">link</a></p>
''',
  r'''[link](/my uri)
''': r'''<p>[link](/my uri)</p>
''',
  r'''[link](</my uri>)
''': r'''<p>[link](&lt;/my uri&gt;)</p>
''',
  r'''[link](foo
bar)
''': r'''<p>[link](foo
bar)</p>
''',
  r'''[link](<foo
bar>)
''': r'''<p>[link](<foo
bar>)</p>
''',
  r'''[link](\(foo\))
''': r'''<p><a href="(foo)">link</a></p>
''',
  r'''[link]((foo)and(bar))
''': r'''<p><a href="(foo)and(bar)">link</a></p>
''',
  r'''[link](foo(and(bar)))
''': r'''<p>[link](foo(and(bar)))</p>
''',
  r'''[link](foo(and\(bar\)))
''': r'''<p><a href="foo(and(bar))">link</a></p>
''',
  r'''[link](<foo(and(bar))>)
''': r'''<p><a href="foo(and(bar))">link</a></p>
''',
  r'''[link](foo\)\:)
''': r'''<p><a href="foo):">link</a></p>
''',
  r'''[link](#fragment)

[link](http://example.com#fragment)

[link](http://example.com?foo=3#frag)
''': r'''<p><a href="#fragment">link</a></p>
<p><a href="http://example.com#fragment">link</a></p>
<p><a href="http://example.com?foo=3#frag">link</a></p>
''',
  r'''[link](foo\bar)
''': r'''<p><a href="foo%5Cbar">link</a></p>
''',
  r'''[link](foo%20b&auml;)
''': r'''<p><a href="foo%20b%C3%A4">link</a></p>
''',
  r'''[link]("title")
''': r'''<p><a href="%22title%22">link</a></p>
''',
  r'''[link](/url "title")
[link](/url 'title')
[link](/url (title))
''': r'''<p><a href="/url" title="title">link</a>
<a href="/url" title="title">link</a>
<a href="/url" title="title">link</a></p>
''',
  r'''[link](/url "title \"&quot;")
''': r'''<p><a href="/url" title="title &quot;&quot;">link</a></p>
''',
  r'''[link](/url "title")
''': r'''<p><a href="/url%C2%A0%22title%22">link</a></p>
''',
  r'''[link](/url "title "and" title")
''': r'''<p>[link](/url &quot;title &quot;and&quot; title&quot;)</p>
''',
  r'''[link](/url 'title "and" title')
''': r'''<p><a href="/url" title="title &quot;and&quot; title">link</a></p>
''',
  r'''[link](   /uri
  "title"  )
''': r'''<p><a href="/uri" title="title">link</a></p>
''',
  r'''[link] (/uri)
''': r'''<p>[link] (/uri)</p>
''',
  r'''[link [foo [bar]]](/uri)
''': r'''<p><a href="/uri">link [foo [bar]]</a></p>
''',
  r'''[link] bar](/uri)
''': r'''<p>[link] bar](/uri)</p>
''',
  r'''[link [bar](/uri)
''': r'''<p>[link <a href="/uri">bar</a></p>
''',
  r'''[link \[bar](/uri)
''': r'''<p><a href="/uri">link [bar</a></p>
''',
  r'''[link *foo **bar** `#`*](/uri)
''': r'''<p><a href="/uri">link <em>foo <strong>bar</strong> <code>#</code></em></a></p>
''',
  r'''[![moon](moon.jpg)](/uri)
''': r'''<p><a href="/uri"><img src="moon.jpg" alt="moon" /></a></p>
''',
  r'''[foo [bar](/uri)](/uri)
''': r'''<p>[foo <a href="/uri">bar</a>](/uri)</p>
''',
  r'''[foo *[bar [baz](/uri)](/uri)*](/uri)
''': r'''<p>[foo <em>[bar <a href="/uri">baz</a>](/uri)</em>](/uri)</p>
''',
  r'''![[[foo](uri1)](uri2)](uri3)
''': r'''<p><img src="uri3" alt="[foo](uri2)" /></p>
''',
  r'''*[foo*](/uri)
''': r'''<p>*<a href="/uri">foo*</a></p>
''',
  r'''[foo *bar](baz*)
''': r'''<p><a href="baz*">foo *bar</a></p>
''',
  r'''*foo [bar* baz]
''': r'''<p><em>foo [bar</em> baz]</p>
''',
  r'''[foo <bar attr="](baz)">
''': r'''<p>[foo <bar attr="](baz)"></p>
''',
  r'''[foo`](/uri)`
''': r'''<p>[foo<code>](/uri)</code></p>
''',
  r'''[foo<http://example.com/?search=](uri)>
''': r'''<p>[foo<a href="http://example.com/?search=%5D(uri)">http://example.com/?search=](uri)</a></p>
''',
  r'''[foo][bar]

[bar]: /url "title"
''': r'''<p><a href="/url" title="title">foo</a></p>
''',
  r'''[link [foo [bar]]][ref]

[ref]: /uri
''': r'''<p><a href="/uri">link [foo [bar]]</a></p>
''',
  r'''[link \[bar][ref]

[ref]: /uri
''': r'''<p><a href="/uri">link [bar</a></p>
''',
  r'''[link *foo **bar** `#`*][ref]

[ref]: /uri
''': r'''<p><a href="/uri">link <em>foo <strong>bar</strong> <code>#</code></em></a></p>
''',
  r'''[![moon](moon.jpg)][ref]

[ref]: /uri
''': r'''<p><a href="/uri"><img src="moon.jpg" alt="moon" /></a></p>
''',
  r'''[foo [bar](/uri)][ref]

[ref]: /uri
''': r'''<p>[foo <a href="/uri">bar</a>]<a href="/uri">ref</a></p>
''',
  r'''[foo *bar [baz][ref]*][ref]

[ref]: /uri
''': r'''<p>[foo <em>bar <a href="/uri">baz</a></em>]<a href="/uri">ref</a></p>
''',
  r'''*[foo*][ref]

[ref]: /uri
''': r'''<p>*<a href="/uri">foo*</a></p>
''',
  r'''[foo *bar][ref]

[ref]: /uri
''': r'''<p><a href="/uri">foo *bar</a></p>
''',
  r'''[foo <bar attr="][ref]">

[ref]: /uri
''': r'''<p>[foo <bar attr="][ref]"></p>
''',
  r'''[foo`][ref]`

[ref]: /uri
''': r'''<p>[foo<code>][ref]</code></p>
''',
  r'''[foo<http://example.com/?search=][ref]>

[ref]: /uri
''': r'''<p>[foo<a href="http://example.com/?search=%5D%5Bref%5D">http://example.com/?search=][ref]</a></p>
''',
  r'''[foo][BaR]

[bar]: /url "title"
''': r'''<p><a href="/url" title="title">foo</a></p>
''',
  r'''[Толпой][Толпой] is a Russian word.

[ТОЛПОЙ]: /url
''': r'''<p><a href="/url">Толпой</a> is a Russian word.</p>
''',
  r'''[Foo
  bar]: /url

[Baz][Foo bar]
''': r'''<p><a href="/url">Baz</a></p>
''',
  r'''[foo] [bar]

[bar]: /url "title"
''': r'''<p>[foo] <a href="/url" title="title">bar</a></p>
''',
  r'''[foo]
[bar]

[bar]: /url "title"
''': r'''<p>[foo]
<a href="/url" title="title">bar</a></p>
''',
  r'''[foo]: /url1

[foo]: /url2

[bar][foo]
''': r'''<p><a href="/url1">bar</a></p>
''',
  r'''[bar][foo\!]

[foo!]: /url
''': r'''<p>[bar][foo!]</p>
''',
  r'''[foo][ref[]

[ref[]: /uri
''': r'''<p>[foo][ref[]</p>
<p>[ref[]: /uri</p>
''',
  r'''[foo][ref[bar]]

[ref[bar]]: /uri
''': r'''<p>[foo][ref[bar]]</p>
<p>[ref[bar]]: /uri</p>
''',
  r'''[[[foo]]]

[[[foo]]]: /url
''': r'''<p>[[[foo]]]</p>
<p>[[[foo]]]: /url</p>
''',
  r'''[foo][ref\[]

[ref\[]: /uri
''': r'''<p><a href="/uri">foo</a></p>
''',
  r'''[bar\\]: /uri

[bar\\]
''': r'''<p><a href="/uri">bar\</a></p>
''',
  r'''[]

[]: /uri
''': r'''<p>[]</p>
<p>[]: /uri</p>
''',
  r'''[
 ]

[
 ]: /uri
''': r'''<p>[
]</p>
<p>[
]: /uri</p>
''',
  r'''[foo][]

[foo]: /url "title"
''': r'''<p><a href="/url" title="title">foo</a></p>
''',
  r'''[*foo* bar][]

[*foo* bar]: /url "title"
''': r'''<p><a href="/url" title="title"><em>foo</em> bar</a></p>
''',
  r'''[Foo][]

[foo]: /url "title"
''': r'''<p><a href="/url" title="title">Foo</a></p>
''',
  r'''[foo] 
[]

[foo]: /url "title"
''': r'''<p><a href="/url" title="title">foo</a>
[]</p>
''',
  r'''[foo]

[foo]: /url "title"
''': r'''<p><a href="/url" title="title">foo</a></p>
''',
  r'''[*foo* bar]

[*foo* bar]: /url "title"
''': r'''<p><a href="/url" title="title"><em>foo</em> bar</a></p>
''',
  r'''[[*foo* bar]]

[*foo* bar]: /url "title"
''': r'''<p>[<a href="/url" title="title"><em>foo</em> bar</a>]</p>
''',
  r'''[[bar [foo]

[foo]: /url
''': r'''<p>[[bar <a href="/url">foo</a></p>
''',
  r'''[Foo]

[foo]: /url "title"
''': r'''<p><a href="/url" title="title">Foo</a></p>
''',
  r'''[foo] bar

[foo]: /url
''': r'''<p><a href="/url">foo</a> bar</p>
''',
  r'''\[foo]

[foo]: /url "title"
''': r'''<p>[foo]</p>
''',
  r'''[foo*]: /url

*[foo*]
''': r'''<p>*<a href="/url">foo*</a></p>
''',
  r'''[foo][bar]

[foo]: /url1
[bar]: /url2
''': r'''<p><a href="/url2">foo</a></p>
''',
  r'''[foo][]

[foo]: /url1
''': r'''<p><a href="/url1">foo</a></p>
''',
  r'''[foo]()

[foo]: /url1
''': r'''<p><a href="">foo</a></p>
''',
  r'''[foo](not a link)

[foo]: /url1
''': r'''<p><a href="/url1">foo</a>(not a link)</p>
''',
  r'''[foo][bar][baz]

[baz]: /url
''': r'''<p>[foo]<a href="/url">bar</a></p>
''',
  r'''[foo][bar][baz]

[baz]: /url1
[bar]: /url2
''': r'''<p><a href="/url2">foo</a><a href="/url1">baz</a></p>
''',
  r'''[foo][bar][baz]

[baz]: /url1
[foo]: /url2
''': r'''<p>[foo]<a href="/url1">bar</a></p>
''',
  r'''![foo](/url "title")
''': r'''<p><img src="/url" alt="foo" title="title" /></p>
''',
  r'''![foo *bar*]

[foo *bar*]: train.jpg "train & tracks"
''': r'''<p><img src="train.jpg" alt="foo bar" title="train &amp; tracks" /></p>
''',
  r'''![foo ![bar](/url)](/url2)
''': r'''<p><img src="/url2" alt="foo bar" /></p>
''',
  r'''![foo [bar](/url)](/url2)
''': r'''<p><img src="/url2" alt="foo bar" /></p>
''',
  r'''![foo *bar*][]

[foo *bar*]: train.jpg "train & tracks"
''': r'''<p><img src="train.jpg" alt="foo bar" title="train &amp; tracks" /></p>
''',
  r'''![foo *bar*][foobar]

[FOOBAR]: train.jpg "train & tracks"
''': r'''<p><img src="train.jpg" alt="foo bar" title="train &amp; tracks" /></p>
''',
  r'''![foo](train.jpg)
''': r'''<p><img src="train.jpg" alt="foo" /></p>
''',
  r'''My ![foo bar](/path/to/train.jpg  "title"   )
''': r'''<p>My <img src="/path/to/train.jpg" alt="foo bar" title="title" /></p>
''',
  r'''![foo](<url>)
''': r'''<p><img src="url" alt="foo" /></p>
''',
  r'''![](/url)
''': r'''<p><img src="/url" alt="" /></p>
''',
  r'''![foo][bar]

[bar]: /url
''': r'''<p><img src="/url" alt="foo" /></p>
''',
  r'''![foo][bar]

[BAR]: /url
''': r'''<p><img src="/url" alt="foo" /></p>
''',
  r'''![foo][]

[foo]: /url "title"
''': r'''<p><img src="/url" alt="foo" title="title" /></p>
''',
  r'''![*foo* bar][]

[*foo* bar]: /url "title"
''': r'''<p><img src="/url" alt="foo bar" title="title" /></p>
''',
  r'''![Foo][]

[foo]: /url "title"
''': r'''<p><img src="/url" alt="Foo" title="title" /></p>
''',
  r'''![foo] 
[]

[foo]: /url "title"
''': r'''<p><img src="/url" alt="foo" title="title" />
[]</p>
''',
  r'''![foo]

[foo]: /url "title"
''': r'''<p><img src="/url" alt="foo" title="title" /></p>
''',
  r'''![*foo* bar]

[*foo* bar]: /url "title"
''': r'''<p><img src="/url" alt="foo bar" title="title" /></p>
''',
  r'''![[foo]]

[[foo]]: /url "title"
''': r'''<p>![[foo]]</p>
<p>[[foo]]: /url &quot;title&quot;</p>
''',
  r'''![Foo]

[foo]: /url "title"
''': r'''<p><img src="/url" alt="Foo" title="title" /></p>
''',
  r'''\!\[foo]

[foo]: /url "title"
''': r'''<p>![foo]</p>
''',
  r'''\![foo]

[foo]: /url "title"
''': r'''<p>!<a href="/url" title="title">foo</a></p>
''',
  r'''<http://foo.bar.baz>
''': r'''<p><a href="http://foo.bar.baz">http://foo.bar.baz</a></p>
''',
  r'''<http://foo.bar.baz/test?q=hello&id=22&boolean>
''': r'''<p><a href="http://foo.bar.baz/test?q=hello&amp;id=22&amp;boolean">http://foo.bar.baz/test?q=hello&amp;id=22&amp;boolean</a></p>
''',
  r'''<irc://foo.bar:2233/baz>
''': r'''<p><a href="irc://foo.bar:2233/baz">irc://foo.bar:2233/baz</a></p>
''',
  r'''<MAILTO:FOO@BAR.BAZ>
''': r'''<p><a href="MAILTO:FOO@BAR.BAZ">MAILTO:FOO@BAR.BAZ</a></p>
''',
  r'''<a+b+c:d>
''': r'''<p><a href="a+b+c:d">a+b+c:d</a></p>
''',
  r'''<made-up-scheme://foo,bar>
''': r'''<p><a href="made-up-scheme://foo,bar">made-up-scheme://foo,bar</a></p>
''',
  r'''<http://../>
''': r'''<p><a href="http://../">http://../</a></p>
''',
  r'''<localhost:5001/foo>
''': r'''<p><a href="localhost:5001/foo">localhost:5001/foo</a></p>
''',
  r'''<http://foo.bar/baz bim>
''': r'''<p>&lt;http://foo.bar/baz bim&gt;</p>
''',
  r'''<http://example.com/\[\>
''': r'''<p><a href="http://example.com/%5C%5B%5C">http://example.com/\[\</a></p>
''',
  r'''<foo@bar.example.com>
''': r'''<p><a href="mailto:foo@bar.example.com">foo@bar.example.com</a></p>
''',
  r'''<foo+special@Bar.baz-bar0.com>
''': r'''<p><a href="mailto:foo+special@Bar.baz-bar0.com">foo+special@Bar.baz-bar0.com</a></p>
''',
  r'''<foo\+@bar.example.com>
''': r'''<p>&lt;foo+@bar.example.com&gt;</p>
''',
  r'''<>
''': r'''<p>&lt;&gt;</p>
''',
  r'''< http://foo.bar >
''': r'''<p>&lt; http://foo.bar &gt;</p>
''',
  r'''<m:abc>
''': r'''<p>&lt;m:abc&gt;</p>
''',
  r'''<foo.bar.baz>
''': r'''<p>&lt;foo.bar.baz&gt;</p>
''',
  r'''http://example.com
''': r'''<p>http://example.com</p>
''',
  r'''foo@bar.example.com
''': r'''<p>foo@bar.example.com</p>
''',
  r'''<a><bab><c2c>
''': r'''<p><a><bab><c2c></p>
''',
  r'''<a/><b2/>
''': r'''<p><a/><b2/></p>
''',
  r'''<a  /><b2
data="foo" >
''': r'''<p><a  /><b2
data="foo" ></p>
''',
  r'''<a foo="bar" bam = 'baz <em>"</em>'
_boolean zoop:33=zoop:33 />
''': r'''<p><a foo="bar" bam = 'baz <em>"</em>'
_boolean zoop:33=zoop:33 /></p>
''',
  r'''Foo <responsive-image src="foo.jpg" />
''': r'''<p>Foo <responsive-image src="foo.jpg" /></p>
''',
  r'''<33> <__>
''': r'''<p>&lt;33&gt; &lt;__&gt;</p>
''',
  r'''<a h*#ref="hi">
''': r'''<p>&lt;a h*#ref=&quot;hi&quot;&gt;</p>
''',
  r'''<a href="hi'> <a href=hi'>
''': r'''<p>&lt;a href=&quot;hi'&gt; &lt;a href=hi'&gt;</p>
''',
  r'''< a><
foo><bar/ >
''': r'''<p>&lt; a&gt;&lt;
foo&gt;&lt;bar/ &gt;</p>
''',
  r'''<a href='bar'title=title>
''': r'''<p>&lt;a href='bar'title=title&gt;</p>
''',
  r'''</a></foo >
''': r'''<p></a></foo ></p>
''',
  r'''</a href="foo">
''': r'''<p>&lt;/a href=&quot;foo&quot;&gt;</p>
''',
  r'''foo <!-- this is a
comment - with hyphen -->
''': r'''<p>foo <!-- this is a
comment - with hyphen --></p>
''',
  r'''foo <!-- not a comment -- two hyphens -->
''': r'''<p>foo &lt;!-- not a comment -- two hyphens --&gt;</p>
''',
  r'''foo <!--> foo -->

foo <!-- foo--->
''': r'''<p>foo &lt;!--&gt; foo --&gt;</p>
<p>foo &lt;!-- foo---&gt;</p>
''',
  r'''foo <?php echo $a; ?>
''': r'''<p>foo <?php echo $a; ?></p>
''',
  r'''foo <!ELEMENT br EMPTY>
''': r'''<p>foo <!ELEMENT br EMPTY></p>
''',
  r'''foo <![CDATA[>&<]]>
''': r'''<p>foo <![CDATA[>&<]]></p>
''',
  r'''foo <a href="&ouml;">
''': r'''<p>foo <a href="&ouml;"></p>
''',
  r'''foo <a href="\*">
''': r'''<p>foo <a href="\*"></p>
''',
  r'''<a href="\"">
''': r'''<p>&lt;a href=&quot;&quot;&quot;&gt;</p>
''',
  r'''foo  
baz
''': r'''<p>foo<br />
baz</p>
''',
  r'''foo\
baz
''': r'''<p>foo<br />
baz</p>
''',
  r'''foo       
baz
''': r'''<p>foo<br />
baz</p>
''',
  r'''foo  
     bar
''': r'''<p>foo<br />
bar</p>
''',
  r'''foo\
     bar
''': r'''<p>foo<br />
bar</p>
''',
  r'''*foo  
bar*
''': r'''<p><em>foo<br />
bar</em></p>
''',
  r'''*foo\
bar*
''': r'''<p><em>foo<br />
bar</em></p>
''',
  r'''`code  
span`
''': r'''<p><code>code span</code></p>
''',
  r'''`code\
span`
''': r'''<p><code>code\ span</code></p>
''',
  r'''<a href="foo  
bar">
''': r'''<p><a href="foo  
bar"></p>
''',
  r'''<a href="foo\
bar">
''': r'''<p><a href="foo\
bar"></p>
''',
  r'''foo\
''': r'''<p>foo\</p>
''',
  r'''foo  
''': r'''<p>foo</p>
''',
  r'''### foo\
''': r'''<h3>foo\</h3>
''',
  r'''### foo  
''': r'''<h3>foo</h3>
''',
  r'''foo
baz
''': r'''<p>foo
baz</p>
''',
  r'''foo 
 baz
''': r'''<p>foo
baz</p>
''',
  r'''hello $.;'there
''': r'''<p>hello $.;'there</p>
''',
  r'''Foo χρῆν
''': r'''<p>Foo χρῆν</p>
''',
  r'''Multiple     spaces
''': r'''<p>Multiple     spaces</p>
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> smartPunctuation
// **************************************************************************

final Map<String, String> _$smartPunctuationTests = <String, String>{
  r'''"Hello," said the spider.
"'Shelob' is my name."
''': r'''<p>“Hello,” said the spider.
“‘Shelob’ is my name.”</p>
''',
  r''''A', 'B', and 'C' are letters.
''': r'''<p>‘A’, ‘B’, and ‘C’ are letters.</p>
''',
  r''''Oak,' 'elm,' and 'beech' are names of trees.
So is 'pine.'
''': r'''<p>‘Oak,’ ‘elm,’ and ‘beech’ are names of trees.
So is ‘pine.’</p>
''',
  r''''He said, "I want to go."'
''': r'''<p>‘He said, “I want to go.”’</p>
''',
  r'''Were you alive in the 70's?
''': r'''<p>Were you alive in the 70’s?</p>
''',
  r'''Here is some quoted '`code`' and a "[quoted link](url)".
''': r'''<p>Here is some quoted ‘<code>code</code>’ and a “<a href="url">quoted link</a>”.</p>
''',
  r''''tis the season to be 'jolly'
''': r'''<p>’tis the season to be ‘jolly’</p>
''',
  r''''We'll use Jane's boat and John's truck,' Jenna said.
''': r'''<p>‘We’ll use Jane’s boat and John’s truck,’ Jenna said.</p>
''',
  r'''"A paragraph with no closing quote.

"Second paragraph by same speaker, in fiction."
''': r'''<p>“A paragraph with no closing quote.</p>
<p>“Second paragraph by same speaker, in fiction.”</p>
''',
  r'''\"This is not smart.\"
This isn\'t either.
5\'8\"
''': r'''<p>&quot;This is not smart.&quot;
This isn't either.
5'8&quot;</p>
''',
  r'''Some dashes:  em---em
en--en
em --- em
en -- en
2--3
''': r'''<p>Some dashes:  em—em
en–en
em — em
en – en
2–3</p>
''',
  r'''one-
two--
three---
four----
five-----
six------
seven-------
eight--------
nine---------
thirteen-------------.
''': r'''<p>one-
two–
three—
four––
five—–
six——
seven—––
eight––––
nine———
thirteen———––.</p>
''',
  r'''Escaped hyphens: \-- \-\-\-.
''': r'''<p>Escaped hyphens: -- ---.</p>
''',
  r'''Ellipses...and...and....
''': r'''<p>Ellipses…and…and….</p>
''',
  r'''No ellipses\.\.\.
''': r'''<p>No ellipses...</p>
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> regression
// **************************************************************************

final Map<String, String> _$regressionTests = <String, String>{
  r'''* foo
→bar
''': r'''<ul>
<li>foo
bar</li>
</ul>
''',
  r'''<a>  
x
''': r'''<a>  
x
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> markdownToMarkdown
// **************************************************************************

final Map<String, String> _$markdownToMarkdownTests = <String, String>{
  r'''Test!
''': r'''Test!
''',
  r'''Paragraph
        Paragraph
''': r'''Paragraph
Paragraph
''',
  r'''\*&nbsp;a&nbsp;*
''': r'''\*&nbsp;a&nbsp;\*
''',
  r'''\---
''': r'''\---
''',
  r'''  \*\*\*
  \-\-\-
  \_\_\_
''': r'''\***
\---
\___
''',
  r'''\*\*\*

\-\-\-

\_\_\_

 \*\*\*

 \-\-\-

 \_\_\_

  \*\*\*
  \-\-\-
  \_\_\_

   \*\*\*
   \-\-\-
   \_\_\_

    \*\*\*
    \-\-\-
    \_\_\_
''': r'''\***

\---

\___

\***

\---

\___

\***
\---
\___

\***
\---
\___

    \*\*\*
    \-\-\-
    \_\_\_
''',
  r'''\### Not a header
''': r'''\### Not a header
''',
  r'''    ### Not a header
''': r'''    ### Not a header
''',
  r'''Paragraph
\# Without a header
''': r'''Paragraph
\# Without a header
''',
  r'''# ## Header
''': r'''# ## Header
''',
  r'''\###### Not a header
''': r'''\###### Not a header
''',
  r'''####### Not a header
''': r'''####### Not a header
''',
  r'''#Not a header
''': r'''#Not a header
''',
  r'''# Header \#\#\#
''': r'''# Header \###
''',
  r'''# Header \#
''': r'''# Header \#
''',
  r'''# Header \#\# Header #
''': r'''# Header ## Header
''',
  r'''Not a header
\=\=\=\=\=\=
''': r'''Not a header
\======
''',
  r'''Not a header
\=\=\=\=\=\= A \=\=\=\=\=\=
''': r'''Not a header
====== A ======
''',
  r'''Not a header
\-\-\-\-\-\-
''': r'''Not a header
\------
''',
  r'''Not a header
\-\-\-\-\-\- A \-\-\-\-\-\-
''': r'''Not a header
------ A ------
''',
  r'''\    Not a code
''': r'''\\    Not a code
''',
  r'''\~\~\~
Not a code
\~\~\~
''': r'''\~~~
Not a code
\~~~
''',
  r'''\`\`\`
Not a code
\`\`\`
''': r'''\```
Not a code
\```
''',
  r'''\<td>
''': r'''\<td\>
''',
  r'''< td >
''': r'''< td >
''',
  r'''\[foo]: /url "title"
''': r'''\[foo]: /url "title"
''',
  r'''*a
''': r'''*a
''',
  r'''- a

-
- b
''': r'''- a

-

- b
''',
  r'''1. a
2.

3. b
''': r'''1. a

2.

3. b
''',
  r'''[reference][reference]

[reference]: reference
''': r'''[reference]


[reference]: reference
''',
  r'''[reference][reference][reference]

[reference]: reference
''': r'''[reference][reference]


[reference]: reference
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> additionalMarkdownToHtml
// **************************************************************************

final Map<String, String> _$additionalMarkdownToHtmlTests = <String, String>{
  r'''Simple test
''': r'''<p>Simple test</p>
''',
  r'''*
''': r'''<ul>
<li></li>
</ul>
''',
  r'''- - ```
    a


    b
    ```
''': r'''<ul>
<li>
<ul>
<li>
<pre><code>a


b
</code></pre>
</li>
</ul>
</li>
</ul>
''',
  r'''- - ```
    a


   b
    ```
''': r'''<ul>
<li>
<ul>
<li>
<pre><code>a


</code></pre>
</li>
</ul>
b
<pre><code></code></pre>
</li>
</ul>
''',
  r'''- - c
  - ```
    a


    b
    ```
''': r'''<ul>
<li>
<ul>
<li>c</li>
<li>
<pre><code>a


b
</code></pre>
</li>
</ul>
</li>
</ul>
''',
  r'''-
  foo
-
 ```
 bar
 ```
-
      baz
''': r'''<ul>
<li>foo</li>
<li></li>
</ul>
<pre><code>bar
</code></pre>
<ul>
<li>
<pre><code>baz
</code></pre>
</li>
</ul>
''',
  r'''-
  foo
-
  ```
  bar
 ```
-
      baz
''': r'''<ul>
<li>foo</li>
<li>
<pre><code>bar
</code></pre>
</li>
</ul>
<pre><code>-
     baz
</code></pre>
''',
  r'''- -
  - - -
''': r'''<ul>
<li>
<ul>
<li></li>
</ul>
<hr />
</li>
</ul>
''',
  r'''```
-
''': r'''<pre><code>-
</code></pre>
''',
  r'''<!--

*a*
''': r'''<!--

*a*
''',
  r'''<?php

*a*
''': r'''<?php

*a*
''',
  r'''[foo](</f&ouml;&ouml;> "f&ouml;&ouml;")
''': r'''<p><a href="/f%C3%B6%C3%B6" title="föö">foo</a></p>
''',
  r'''* a

*␣
* c
''': r'''<ul>
<li>
<p>a</p>
</li>
<li></li>
<li>
<p>c</p>
</li>
</ul>
''',
  r'''1. a

2.␣
3. c
''': r'''<ol>
<li>
<p>a</p>
</li>
<li></li>
<li>
<p>c</p>
</li>
</ol>
''',
  r'''* foo

  * bar

  baz
''': r'''<ul>
<li>
<p>foo</p>
<ul>
<li>bar</li>
</ul>
<p>baz</p>
</li>
</ul>
''',
  r'''1. a
   1. b

      c
2. d
''': r'''<ol>
<li>a
<ol>
<li>
<p>b</p>
<p>c</p>
</li>
</ol>
</li>
<li>d</li>
</ol>
''',
  r'''*__a__*
''': r'''<p><em><strong>a</strong></em></p>
''',
  r'''1. fads
   ----
''': r'''<ol>
<li>
<h2>fads</h2>
</li>
</ol>
''',
  r'''1. a
b
c
''': r'''<ol>
<li>a
b
c</li>
</ol>
''',
  r'''No header
\===
''': r'''<p>No header
===</p>
''',
  r'''> a
b
c
''': r'''<blockquote>
<p>a
b
c</p>
</blockquote>
''',
  r''' *     * ````

       *
''': r'''<ul>
<li>
<pre><code>* ````

*
</code></pre>
</li>
</ul>
''',
  r'''  -→foo

→bar
''': r'''<ul>
<li>
<p>foo</p>
<p>bar</p>
</li>
</ul>
''',
  r'''  -→→foo

→→bar
''': r'''<ul>
<li>
<pre><code>foo

bar
</code></pre>
</li>
</ul>
''',
  r'''-
  -
        asdf
''': r'''<ul>
<li>
<ul>
<li>
<pre><code>asdf
</code></pre>
</li>
</ul>
</li>
</ul>
''',
  r'''[foo](/f&#246;&#246; "f&#246;&#246;")
''': r'''<p><a href="/f%C3%B6%C3%B6" title="föö">foo</a></p>
''',
  r'''[foo](/f&#xf6;&#xf6; "f&#xf6;&#xf6;")
''': r'''<p><a href="/f%C3%B6%C3%B6" title="föö">foo</a></p>
''',
  r'''[foo](/f&zzzz;&zzzz; "f&zzzz;&zzzz;")
''': r'''<p><a href="/f&zzzz;&zzzz;" title="f&amp;zzzz;&amp;zzzz;">foo</a></p>
''',
  r'''&#160;
''': r'''<p> </p>
''',
  r'''[foo **[bar]**](/uri)
''': r'''<p><a href="/uri">foo <strong>[bar]</strong></a></p>
''',
  r'''[foo ~~[bar]~~](/uri)
''': r'''<p><a href="/uri">foo <del>[bar]</del></a></p>
''',
  r'''[foo ^[bar]^](/uri)
''': r'''<p><a href="/uri">foo <sup>[bar]</sup></a></p>
''',
  r'''[foo ~[bar]~](/uri)
''': r'''<p><a href="/uri">foo <sub>[bar]</sub></a></p>
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> fencedCodeAttributes
// **************************************************************************

final Map<String, String> _$fencedCodeAttributesTests = <String, String>{
  r'''``` {#id}
code
```
''': r'''<pre id="id"><code>code
</code></pre>
''',
  r'''``` {.class}
code
```
''': r'''<pre class="class"><code>code
</code></pre>
''',
  r'''``` {width=800}
code
```
''': r'''<pre width="800"><code>code
</code></pre>
''',
  r'''``` {width='800'}
code
```
''': r'''<pre width="800"><code>code
</code></pre>
''',
  r'''``` {width="800"}
code
```
''': r'''<pre width="800"><code>code
</code></pre>
''',
  r'''``` {key1=value1  key2=value2}
code
```
''': r'''<pre key1="value1" key2="value2"><code>code
</code></pre>
''',
  r'''``` {#id.class1.class2 width="800"}
code
```
''': r'''<pre id="id" class="class1 class2" width="800"><code>code
</code></pre>
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> headingAttributes
// **************************************************************************

final Map<String, String> _$headingAttributesTests = <String, String>{
  r'''# header {#id}
''': r'''<h1 id="id">header</h1>
''',
  r'''# header {.class}
''': r'''<h1 class="class">header</h1>
''',
  r'''# header {width=800}
''': r'''<h1 width="800">header</h1>
''',
  r'''# header {width='800'}
''': r'''<h1 width="800">header</h1>
''',
  r'''# header {width="800"}
''': r'''<h1 width="800">header</h1>
''',
  r'''# header {key1=value1  key2=value2}
''': r'''<h1 key1="value1" key2="value2">header</h1>
''',
  r'''# header {#id.class1.class2 width="800"}
''': r'''<h1 id="id" class="class1 class2" width="800">header</h1>
''',
  r'''header {#id}
============
''': r'''<h1 id="id">header</h1>
''',
  r'''header {.class}
===============
''': r'''<h1 class="class">header</h1>
''',
  r'''header {width=800}
==================
''': r'''<h1 width="800">header</h1>
''',
  r'''header {width='800'}
====================
''': r'''<h1 width="800">header</h1>
''',
  r'''header {width="800"}
====================
''': r'''<h1 width="800">header</h1>
''',
  r'''header {key1=value1  key2=value2}
=================================
''': r'''<h1 key1="value1" key2="value2">header</h1>
''',
  r'''header {#id.class1.class2 width="800"}
======================================
''': r'''<h1 id="id" class="class1 class2" width="800">header</h1>
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> inlineCodeAttributes
// **************************************************************************

final Map<String, String> _$inlineCodeAttributesTests = <String, String>{
  r'''`code`{#id}
''': r'''<p><code id="id">code</code></p>
''',
  r'''`code`{.class}
''': r'''<p><code class="class">code</code></p>
''',
  r'''`code`{width=800}
''': r'''<p><code width="800">code</code></p>
''',
  r'''`code`{width='800'}
''': r'''<p><code width="800">code</code></p>
''',
  r'''`code`{width="800"}
''': r'''<p><code width="800">code</code></p>
''',
  r'''`code`{key1=value1  key2=value2}
''': r'''<p><code key1="value1" key2="value2">code</code></p>
''',
  r'''`code`{#id.class1.class2 width="800"}
''': r'''<p><code id="id" class="class1 class2" width="800">code</code></p>
''',
  r'''`code`{#id.class1.class2
width="800"}
''': r'''<p><code id="id" class="class1 class2" width="800">code</code></p>
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> linkAttributes
// **************************************************************************

final Map<String, String> _$linkAttributesTests = <String, String>{
  r'''[test](http://test.com/){#id}
''': r'''<p><a href="http://test.com/" id="id">test</a></p>
''',
  r'''[test](http://test.com/){.class}
''': r'''<p><a href="http://test.com/" class="class">test</a></p>
''',
  r'''[test](http://test.com/){width=800}
''': r'''<p><a href="http://test.com/" width="800">test</a></p>
''',
  r'''[test](http://test.com/){width='800'}
''': r'''<p><a href="http://test.com/" width="800">test</a></p>
''',
  r'''[test](http://test.com/){width="800"}
''': r'''<p><a href="http://test.com/" width="800">test</a></p>
''',
  r'''[test](http://test.com/){attr="with \" quote"}
''': r'''<p><a href="http://test.com/">test</a>{attr=&quot;with &quot; quote&quot;}</p>
''',
  r'''[test](http://test.com/){key1=value1  key2=value2}
''': r'''<p><a href="http://test.com/" key1="value1" key2="value2">test</a></p>
''',
  r'''[test](http://test.com/){#id.class1.class2 width="800"}
''': r'''<p><a href="http://test.com/" id="id" class="class1 class2" width="800">test</a></p>
''',
  r'''[test](http://test.com/){#id.class1.class2
width="800"}
''': r'''<p><a href="http://test.com/" id="id" class="class1 class2" width="800">test</a></p>
''',
  r'''[test][ref]

[ref]: http://test.com/ {#id}
''': r'''<p><a href="http://test.com/" id="id">test</a></p>
''',
  r'''[test][ref]

[ref]: http://test.com/ {.class}
''': r'''<p><a href="http://test.com/" class="class">test</a></p>
''',
  r'''[test][ref]

[ref]: http://test.com/ {width=800}
''': r'''<p><a href="http://test.com/" width="800">test</a></p>
''',
  r'''[test][ref]

[ref]: http://test.com/ {width='800'}
''': r'''<p><a href="http://test.com/" width="800">test</a></p>
''',
  r'''[test][ref]

[ref]: http://test.com/ {width="800"}
''': r'''<p><a href="http://test.com/" width="800">test</a></p>
''',
  r'''[test][ref]

[ref]: http://test.com/ {key1=value1  key2=value2}
''': r'''<p><a href="http://test.com/" key1="value1" key2="value2">test</a></p>
''',
  r'''[test][ref]

[ref]: http://test.com/ {#id.class1.class2 width="800"}
''': r'''<p><a href="http://test.com/" id="id" class="class1 class2" width="800">test</a></p>
''',
  r'''[test][ref]

[ref]: http://test.com/ {#id.class1.class2
width="800"}
''': r'''<p><a href="http://test.com/" id="id" class="class1 class2" width="800">test</a></p>
''',
  r'''![test](http://test.com/){#id}
''': r'''<p><img src="http://test.com/" alt="test" id="id" /></p>
''',
  r'''![test](http://test.com/){.class}
''': r'''<p><img src="http://test.com/" alt="test" class="class" /></p>
''',
  r'''![test](http://test.com/){width=800}
''': r'''<p><img src="http://test.com/" alt="test" width="800" /></p>
''',
  r'''![test](http://test.com/){width='800'}
''': r'''<p><img src="http://test.com/" alt="test" width="800" /></p>
''',
  r'''![test](http://test.com/){width="800"}
''': r'''<p><img src="http://test.com/" alt="test" width="800" /></p>
''',
  r'''![test](http://test.com/){key1=value1  key2=value2}
''': r'''<p><img src="http://test.com/" alt="test" key1="value1" key2="value2" /></p>
''',
  r'''![test](http://test.com/){#id.class1.class2 width="800"}
''': r'''<p><img src="http://test.com/" alt="test" id="id" class="class1 class2" width="800" /></p>
''',
  r'''![test](http://test.com/){#id.class1.class2
width="800"}
''': r'''<p><img src="http://test.com/" alt="test" id="id" class="class1 class2" width="800" /></p>
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> strikeout
// **************************************************************************

final Map<String, String> _$strikeoutTests = <String, String>{
  r'''~~Strikeout text~~
''': r'''<p><del>Strikeout text</del></p>
''',
  r'''~~__Strikeout text__~~
''': r'''<p><del><strong>Strikeout text</strong></del></p>
''',
  r'''Ins~~e~~ide w~~a~~ord
''': r'''<p>Ins<del>e</del>ide w<del>a</del>ord</p>
''',
  r'''~~~Strikeout text~~~
''': r'''<p>~<del>Strikeout text</del>~</p>
''',
  r'''~~~~Strikeout text~~~~
''': r'''<p><del><del>Strikeout text</del></del></p>
''',
  r'''~\~No strikeout~~
''': r'''<p>~~No strikeout~~</p>
''',
  r'''\~~No strikeout~~
''': r'''<p>~~No strikeout~~</p>
''',
  r'''~No strikeout~
''': r'''<p>~No strikeout~</p>
''',
  r'''~~ this ~~ is not one neither is ~this~
''': r'''<p>~~ this ~~ is not one neither is ~this~</p>
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> strikeoutAndSubscript
// **************************************************************************

final Map<String, String> _$strikeoutAndSubscriptTests = <String, String>{
  r'''~~Strikeout text~~
''': r'''<p><del>Strikeout text</del></p>
''',
  r'''~~__Strikeout text__~~
''': r'''<p><del><strong>Strikeout text</strong></del></p>
''',
  r'''Ins~~e~~ide w~~a~~ord
''': r'''<p>Ins<del>e</del>ide w<del>a</del>ord</p>
''',
  r'''~\~No strikeout~~
''': r'''<p>~~No strikeout~~</p>
''',
  r'''\~~No strikeout~~
''': r'''<p>~~No strikeout~~</p>
''',
  r'''~\~No\ strikeout~~
''': r'''<p><sub>~No strikeout</sub>~</p>
''',
  r'''\~~No\ strikeout~~
''': r'''<p>~<sub>No strikeout</sub>~</p>
''',
  r'''~~No\ strikeout~~
''': r'''<p><del>No\ strikeout</del></p>
''',
  r'''~No strikeout~
''': r'''<p>~No strikeout~</p>
''',
  r'''~~~No\ strikeout~~~
''': r'''<p><sub><del>No strikeout</del></sub></p>
''',
  r'''~~~No strikeout~~~
''': r'''<p>~<del>No strikeout</del>~</p>
''',
  r'''~~ this ~~ is not one neither is ~this~
''': r'''<p>~~ this ~~ is not one neither is <sub>this</sub></p>
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> subscript
// **************************************************************************

final Map<String, String> _$subscriptTests = <String, String>{
  r'''H~2~O
''': r'''<p>H<sub>2</sub>O</p>
''',
  r'''H~2 0~O
''': r'''<p>H~2 0~O</p>
''',
  r'''H~2→0~O
''': r'''<p>H~2→0~O</p>
''',
  r'''H~2\ 0~O
''': r'''<p>H<sub>2 0</sub>O</p>
''',
  r'''H~2\→0~O
''': r'''<p>H<sub>2→0</sub>O</p>
''',
  r'''H~2\ 0
''': r'''<p>H~2\ 0</p>
''',
  r'''H~2\→0
''': r'''<p>H~2\→0</p>
''',
  r'''H~*2\ 0*~O
''': r'''<p>H<sub><em>2 0</em></sub>O</p>
''',
  r'''H*~2\ 0~*O
''': r'''<p>H<em><sub>2 0</sub></em>O</p>
''',
  r'''H~~2~~
''': r'''<p>H~~2~~</p>
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> superscript
// **************************************************************************

final Map<String, String> _$superscriptTests = <String, String>{
  r'''2^2^=4
''': r'''<p>2<sup>2</sup>=4</p>
''',
  r'''2^2 0^=4
''': r'''<p>2^2 0^=4</p>
''',
  r'''2^2→0^=4
''': r'''<p>2^2→0^=4</p>
''',
  r'''2^2\ 0^=4
''': r'''<p>2<sup>2 0</sup>=4</p>
''',
  r'''2^2\→0^=4
''': r'''<p>2<sup>2→0</sup>=4</p>
''',
  r'''2^2\ 0
''': r'''<p>2^2\ 0</p>
''',
  r'''2^2\→0
''': r'''<p>2^2\→0</p>
''',
  r'''2^*2\ 0*^=4
''': r'''<p>2<sup><em>2 0</em></sup>=4</p>
''',
  r'''H*^2\ 0^*O
''': r'''<p>H<em><sup>2 0</sup></em>O</p>
''',
  r'''2^^2^^=4
''': r'''<p>2^^2^^=4</p>
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> texMathDollars
// **************************************************************************

final Map<String, String> _$texMathDollarsTests = <String, String>{
  r'''$a+b=c$
''': r'''<p><span class="math inline">\(a+b=c\)</span></p>
''',
  r'''$ a+b=c$
''': r'''<p>$ a+b=c$</p>
''',
  r'''$a+b=c $
''': r'''<p>$a+b=c $</p>
''',
  r'''$20,000 and $30,000
''': r'''<p>$20,000 and $30,000</p>
''',
  r'''$a+\$b=c$
''': r'''<p><span class="math inline">\(a+$b=c\)</span></p>
''',
  r'''$$a+b=c$$
''': r'''<p><span class="math display">\[a+b=c\]</span></p>
''',
  r'''$$a+\$b=c$$
''': r'''<p><span class="math display">\[a+\$b=c\]</span></p>
''',
  r'''$$a+$b=c$$
''': r'''<p><span class="math display">\[a+$b=c\]</span></p>
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> texMathSingleBackslash
// **************************************************************************

final Map<String, String> _$texMathSingleBackslashTests = <String, String>{
  r'''$a+b=c$
''': r'''<p>$a+b=c$</p>
''',
  r'''\(a+b=c\)
''': r'''<p><span class="math inline">\(a+b=c\)</span></p>
''',
  r'''\(a+b=
c\)
''': r'''<p><span class="math inline">\(a+b=
c\)</span></p>
''',
  r'''\[a+b=c\]
''': r'''<p><span class="math display">\[a+b=c\]</span></p>
''',
  r'''\(a+b=c\]
''': r'''<p>(a+b=c]</p>
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> texMathDoubleBackslash
// **************************************************************************

final Map<String, String> _$texMathDoubleBackslashTests = <String, String>{
  r'''$a+b=c$
''': r'''<p>$a+b=c$</p>
''',
  r'''\\(a+b=c\\)
''': r'''<p><span class="math inline">\(a+b=c\)</span></p>
''',
  r'''\(a+b=c\)
''': r'''<p>(a+b=c)</p>
''',
  r'''\\(a+b=
c\\)
''': r'''<p><span class="math inline">\(a+b=
c\)</span></p>
''',
  r'''\\[a+b=c\\]
''': r'''<p><span class="math display">\[a+b=c\]</span></p>
''',
  r'''\\(a+b=c\\]
''': r'''<p>\(a+b=c\]</p>
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> texMathCustomClasses
// **************************************************************************

final Map<String, String> _$texMathCustomClassesTests = <String, String>{
  r'''$a+b=c$
''': r'''<p><span class="custom_inline">\(a+b=c\)</span></p>
''',
  r'''$$a+b=c$$
''': r'''<p><span class="custom_display">\[a+b=c\]</span></p>
''',
};

// **************************************************************************
// Generator: EmbedTestsGenerator
// Target: final Map<String, String> rawTex
// **************************************************************************

final Map<String, String> _$rawTexTests = <String, String>{
  r'''This is the identity matrix:

\begin{pmatrix}
1 & 0 & 0 \\
0 & 1 & 0 \\
0 & 0 &1 \\
\end{pmatrix}
''': r'''<p>This is the identity matrix:</p>

\begin{pmatrix}
1 &amp; 0 &amp; 0 \\
0 &amp; 1 &amp; 0 \\
0 &amp; 0 &amp;1 \\
\end{pmatrix}
''',
  r'''This is the identity matrix:

\begin{pmatrix}
1 & 0 & 0 \\
0 & 1 & 0 \\
0 & 0 &1 \\


\end{pmatrix}
''': r'''<p>This is the identity matrix:</p>

\begin{pmatrix}
1 &amp; 0 &amp; 0 \\
0 &amp; 1 &amp; 0 \\
0 &amp; 0 &amp;1 \\


\end{pmatrix}
''',
  r'''\begin{theorem}[Fred]
All odd numbers are prime.
\end{theorem}
''': r'''\begin{theorem}[Fred]
All odd numbers are prime.
\end{theorem}
''',
  r'''\begin{theorem*}[Fred]
All odd numbers are prime.
\end{theorem}
''': r'''<p>\begin{theorem*}[Fred]
All odd numbers are prime.
\end{theorem}</p>
''',
};
