---
layout: post
title: Help! My Xcode Extensions Disappeared
description: How to fix this unfortunately common problem.
tags: [development, xcode]
---

Have your Xcode Extensions ever just… disappeared on you (usually after a crash)?

They'll be completely missing from the `Editor` menu item in Xcode itself, but _also missing from the Extensions area of System Preferences_.

Well you're in luck, I have a simple solution for you.

1. Quit Xcode Completely
2. Go to `/Applications` (where Xcode.app is installed)
3. RENAME Xcode to something (I usually just add a space before ".app") and hit Enter
4. Revert Xcode to it's original name.
5. There is no step 5.

---

# Why?

From Zoë Smith, [writing at NSHipster](https://nshipster.com/xcode-source-extensions/):

<figure class="quote">
  <blockquote cite="https://nshipster.com/xcode-source-extensions/">
    <p>when multiple copies of Xcode are on the same machine, extensions can stop working completely. In this case, Apple Developer Relations suggests re-registering your main copy of Xcode with Launch Services…</p>
  </blockquote>
  <figcaption>&mdash;Zoë Smith, <cite>NSHipster</cite></figcaption>
</figure>

That's all we're doing when we rename Xcode, we're simply re-registering it with Launch Services. 