# Phoenix-vue app with nanobox

## Installation instructions/logs (how this repo was created)

#### Create and cd into work directory
```
mkdir -p ~/src/phoenix-vue
cd ~/src/phoenix-vue
```

#### Create the boxfile
```
cat > boxfile.yml <<'EOF'
run.config:  
  engine: elixir
  extra_packages:
    - nodejs
  dev_packages:
    - inotify-tools
  cache_dirs:
    - node_modules
  extra_path_dirs:
    - node_modules/.bin
  fs_watch: true

data.db:  
  image: nanobox/postgresql:9.5

web.site:  
  start: mix phoenix.server
EOF
```

#### Add the dns entry
```
nanobox dns add local phoenix-vue.dev
```

#### Install and configure phoenix
```
nanobox run
mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez
cd /tmp
mix phoenix.new app
cd -

shopt -s dotglob
cp -a /tmp/app/* .

cat > brunch-config.js <<'EOF'
exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: "js/app.js"

      // To use a separate vendor.js bundle, specify two files path
      // http://brunch.io/docs/config#-files-
      // joinTo: {
      //  "js/app.js": /^(web\/static\/js)/,
      //  "js/vendor.js": /^(web\/static\/vendor)|(deps)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      // order: {
      //   before: [
      //     "web/static/vendor/js/jquery-2.1.1.js",
      //     "web/static/vendor/js/bootstrap.min.js"
      //   ]
      // }
    },
    stylesheets: {
      joinTo: "css/app.css",
      order: {
        after: ["web/static/css/app.css"] // concat app.css last
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/web/static/assets". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "web/static",
      "test/static"
    ],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"]
    }
  },

  npm: {  
    enabled: true,
    whitelist: ["phoenix", "phoenix_html", "vue"],
    globals: {
      Vue: "vue/dist/vue.common.js"
    },
  }
};
EOF

brunch build

cat > web/templates/page/index.html.eex <<'EOF'
<div id="hello-world">
  {{message}}
</div>
EOF

cat >> web/static/js/app.js <<'EOF'
new Vue({
  el: "#hello-world",
  data: {
    message: "Hello World"
  }
});
EOF
```

#### Set config files to use env vars
```sh
for i in config/dev.exs config/test.exs config/prod.secret.exs; do
  sed -i 's/username:.*/username: System.get_env("DATA_DB_USER"),/g' $i
  sed -i 's/password:.*/password: System.get_env("DATA_DB_PASS"),/g' $i
  sed -i 's/hostname:.*/hostname: System.get_env("DATA_DB_HOST"),/g' $i
  sed -i 's/database:.*/database: "gonano",/g' $i
done

# ensure port is set for production
sed -i 's/^  http:.*/  http: [port: 8080],/g' config/prod.exs
sed -i 's/^  url:.*/  url: [host: "my-phoenix.nanoapp.io", port: 80],/g' config/prod.exs
```
**Note:** Ensure config/prod.secret.exs contains the hostname declaration

#### Run and develop locally (while in `nanobox run`)
```sh
mix phoenix.server
```

#### Link local work directory to app on nanobox and deploy
```
nanobox remote add my-phoenix
nanobox deploy
```

### DISCLAIMER
While I intend on following all best practices, I am in no way an elixir/phoenix developer and may make mistakes. I make no guarantee as to the condition of this guide.

>Phoenix generated readme
>```md
># App
>
>To start your Phoenix app:
>
>  * Install dependencies with `mix deps.get`
>  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
>  * Install Node.js dependencies with `npm install`
>  * Start Phoenix endpoint with `mix phoenix.server`
>
>Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
>
>Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).
>
>## Learn more
>
>  * Official website: http://www.phoenixframework.org/
>  * Guides: http://phoenixframework.org/docs/overview
>  * Docs: https://hexdocs.pm/phoenix
>  * Mailing list: http://groups.google.com/group/phoenix-talk
>  * Source: https://github.com/phoenixframework/phoenix
>```
