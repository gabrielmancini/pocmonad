# Pocmonad

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `pocmonad` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pocmonad, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/pocmonad](https://hexdocs.pm/pocmonad).

## Publish docs

First put this into a file called post-commit in <your_project>/.git/hooks

```bash
#!/bin/bash
git checkout master
mix docs
cd docs/
git checkout gh-pages
git add .
git commit -m "update documentation"
git push origin gh-pages
```

After that make sure it's executable by using

```
chmod +x <your_project>/.git/hooks/post-commit
```
