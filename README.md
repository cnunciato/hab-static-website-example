# hab-static-website-example

This is an example of one way to package and deliver a static website with [Habitat](https://habitat.sh/) and have it managed independently by the Habitat Supervisor.

It assumes a little knowledge of Habitat, so if you don't yet have that, [take a look at a few demos](https://habitat.sh/learn/) to get a sense of how things work, then come back here when you're ready.

## The Problem

As a web developer, I spend a lot of my time writing front-end code, and most of the time, that code ends up being delivered by a web server that's either totally outside my control or that does a whole lot more than just serve my website. For instance, maybe that server delivers someone else's website also, proxies one or more upstream API services, defines a handful of redirects or error handlers, and a whole bunch of other stuff that has nothing to do with my website. What I'd love to be able to do is treat my little website as a Habitat package of its own, containing only the files it needs, and have Habitat handle the delivery of that package independently of the web server.

The problem, though, is that the Habitat Supervisor &mdash; at least as of today &mdash; doesn't manage non-runnable (what we sometimes call "library") packages of this kind. Even if I wrote a plan to package my website, connected it to [Builder](https://bldr.habitat.sh/) and merged a commit that produced a new package that I promoted to the stable channel, the Supervisor running in production wouldn't know anything about that new package, because it's only watching the depot for updates to the web _server_; it doesn't know anything about the _site_.

This has prompted some users (including us, in some cases) to combine the website and server into a single package and ship that whenever a change is made to either of them &mdash; which certainly works, but also feels strange in that it creates an uncomfortable (and really unnecessary) interdependency that prevents being able to ship one without the other.

## A Solution

This repo contains two Habitat plans: one for a web server, and one for a website. The website package contains only an `index.html` file (representing our static website), and the server package extends Habitat's `core/nginx` package by setting some configuration defaults and exposing a configurable docroot. Both packages run as services under the Habitat Supervisor, which allows them to be updated automatically using Habitat's built-in support for [update strategies](https://www.habitat.sh/docs/using-habitat/#update-strategy).

When a commit is made to the website package (assuming it's connected to Builder), a package is produced containing only the website, and when the package is promoted to `stable`, the Supervisor detects it, installs it, and the already-running web server picks up its changes automatically without having to be restarted.

### Wait &mdash; the static website runs as a service?

Yes &mdash; that's the trick. If we want to get all that goodness from the Supervisor (which again only manages _services_), we need to augment the website package in a way that allows it to "run" as a process. We do that, basically, with a [run hook](https://www.habitat.sh/docs/reference/#hooks) that `sleep`s indefinitely:

```
# website/habitat/hooks/run

while true
do
  sleep 86400
end
```

Coupled with an `init` hook that links our website files as a directory under `/hab/svc`:

```
# website/habitat/hooks/init

ln -sf {{ pkg.path }}/www {{ pkg.svc_static_path }}/
```

... we're able to configure the web server's docroot:

```
# server/habitat/default.toml
...

[http.server]
...
root = "/hab/svc/hab-static-website/static/www"
index = "index.html"
```

... and the two packages run as indepedently managed services under the Supervisor.

Not perfect for everyone, perhaps, but hey &mdash; it definitely works!

## Try it Out

Assuming you have [Vagrant](https://www.vagrantup.com/) installed (and are running the VMWare Fusion plugin -- feel free to tweak as apprioriate if you aren't), you can see how this works with a:

```
vagrant up
```

That'll install Habitat, set up a Systemd unit for the Supervisor, and start it. Then you can enter the VM, load your services, and tail the logs to see what's happening.

```
vagrant ssh
sudo hab svc load cnunciato/hab-static-website --strategy at-once
sudo hab svc load cnunciato/hab-static-server --strategy at-once
sudo journalctl -fu hab-sup
```

You should also be able to browse to the website at http://localhost.

## Author

Christian Nunciato (chris@nunciato.org)

