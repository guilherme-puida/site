Sometimes I need to push to the remote to trigger CI workflows. This can happen
if I don't have the necessary permissions to use the web interface.

To avoid pushing garbage, I like using empty commits.

```bash
git commit --allow-empty -m 'fixme: triggering build' && git push
```

After I trigger the build and if succeeds (or fails), I rebase and drop the
empty commits. Prefixing the message with `fixme` helps to identify what I
should drop.
