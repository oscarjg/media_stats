# MediaStats

#### RELEASE CODE TO PRODUCTION

**Create a new release**
```
sh deploy release_version install 
/var/www/media_stats/bin/media_stats_umbrella start
```

**Upgrade a release**
```
sh deploy release_version upgrade
/var/www/media_stats/bin/media_stats_umbrella upgrade release_version
```

**Connect to remote hosts from local**

```
//Check ssh access and ports redirects
ssh root@148.251.47.102 -L 4369:127.0.0.1:4369

// Start iex session with the cookie set on rel/config.exs or check server status
iex --name debug --cookie 46IIVqnilE2ogh76cmcOZ7DNqbSQOK6LlNqtxmn6fyiPCqdnmD
iex> Node.connect(:"media_stats_umbrella@148.251.47.102")
```

**Run observer from local to remote**

```
iex --name debug --cookie 46IIVqnilE2ogh76cmcOZ7DNqbSQOK6LlNqtxmn6fyiPCqdnmD

iex> Node.connect(:"media_stats_umbrella@148.251.47.102")
iex> :observer.start
```

**Server actions**
```
// Your local machine must be access to remote wihtout pass

// Check server status
/var/www/media_stats/bin/media_stats_umbrella describe

// Stop server
/var/www/media_stats/bin/media_stats_umbrella stop

// Start server
/var/www/media_stats/bin/media_stats_umbrella start

// Start as foreground server
/var/www/media_stats/bin/media_stats_umbrella foreground
```

#### Javascript libraries

**Pusher**

```
<script src="https://ms.comitium.io/js/pusher.js"></script>
<script>
    Pusher.init({
        app_key: "your_app_key"
    })
</script>
```
 

