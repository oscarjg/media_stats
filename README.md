# MediaStats

####RELEASE CODE TO PRODUCTION

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

**Remote server actions from local**
```
// Your local machine must be access to remote wihtout pass

// Check server status
sh server.sh describe

// Stop server
sh server.sh stop

// Start server
sh server.sh start

// Foreground server
sh server.sh foreground
```
 

