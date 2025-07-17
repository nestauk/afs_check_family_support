# Check Family Support

## About

This quick protoype (<10hrs development time - features may be incomplete and expect bugs) allows...

1. Parents/carers of unders 5's to check eligibility for multiple family support services by completing a single short form;
2. Family support managers such as local authorities or Family Hubs get insights about demand and manage information about family support services in their area.

This prototype is **currently exploring** the following assumptions...

- **One form, many services:** What's the smallest amout of data we need from parents to match them to evidence based parenting interventions and support services. Can we turn this into a valuable and useful tool? How might we make it easier for parents/carers to find and sign up to evidence based services over others? How much value can we provide before needing to make it easier to sign up to services locally (which is currently tricky due to digital maturity locally)?
- **A value-loop for service providers:** Data standards, as well as consistent and comprehensive data are important. However the data availability and consistency on family support services is mixed. What's the minimum amount of data we need from local areas/service providers to provide a useful tool to parents/carers? How might we make it valuable/useful for local areas/service providers to provide and manage information about services (initally the basics, but in future hopefully data about service availability and performance) and reduce the data input burden? Can we leverage this value-loop to improve the quality and consistency of family support service data for the sector as a public good?

**Options for future** for future exploration could include...

- **Initial release:** Refining this prototype so it's robust enough to be publically deployed and used as an initial early stage relase.
- **Minimum viable data:** Populate the tool with data from 1-2 target local areas/service providers so it can be used to be matched to actual family support services in these areas.
- **Safe local testing:** Test the prototype in a safe and controlled way in 1-2 target local areas.
- **Additional features:** Allow parent/carers to sign up to services or make structured referalls + associated features for local areas/service providers to manage referalls. Features to track service completion and performance. Etc.

---

## Development principles

### Keep it simple

Resist the temptation to over-engineer. Building a new platform brings
significant complexity; we should work to minimise that complexity. Start with
the simplest thing that works and iterate if required.

### Bias towards deployment

Develop and deploy simple end-to-end functionality before adding complexity.
Deploying early and often reduces the risk of bugs, and allows us to get
feedback early on in the development cycle.

### Embrace the framework

Rails and other frameworks have well established conventions. We should 'embrace
the framework', using the conventional approach most of the time.

### Add value with tests

Aim to spend about 20% of your time writing tests. Avoid testing the framework,
and focus on testing our code. The majority of tests should be functional
[feature tests], supplemented by unit testing and browser testing.

## Tech Stack

### Local development

Docker has been setup for local development and testing. The [docker-compose]
file defines services for running the database and webserver, managing the
frontend assets, and running an email server that intercepts any outgoing
emails. See [setup] for how to get docker up and running.

Once the docker services have been started, you can access the web server at
http://127.0.0.1:3000, you can connect to the postgres database using port 5433,
username "pgsql" and password "password", and you can see any emails the app
sends on the Mailpit email server at http://127.0.0.1:8025.

### Deployment

This project is deployed by Heroku. Deployments are triggered manually in the Heroku
web app. See the [app.json](app.json) configuration file used by Heroku.

### Backend

The backend is powered by Ruby on Rails with a Postgres database. Templating is
powered by [RBlade]. The rails webserver is powered by Puma. MiniTest is used
for testing, and Capybara and Cuprite are used for browser testing, using the
chromium driver installed on the docker image. Caching is powered by solid_cache,
which uses the Postgres database.

### Frontend

Frontend assets - javascript, stylesheets, fonts and images - are stored in
the [app/frontend](app/frontend) folder, and templates are stored in the
[app/views](app/views) folder. Additionally, the [components](app/views/components)
subfolder contains components used throughout the site, which can also be
previewed on the [component library] page.

### Vite

The frontend assets are compiled and bundled by [vite_rails]. The `vite` docker
service keeps the frontend files up to date, and provides hot module reloading
(HMR) when developing locally: when you make a change to a file, any open
browser tabs will automatically be updated with the changes.

On the production and staging servers, vite hooks into the rails
`assets:precompile` command to build the app's assets so no further
configuration is required.

Assets can be used on a page using an [entrypoint]; an entrypoint defines a
package of frontend assets. By default, all pages in the site include the
[application entrypoint], which loads the app stylesheet, AlpineJS and Turbo.
Additional entrypoints can be included as required.

### Javascript & Typescript

This project uses [Typescript](tsconfig.json), which is compiled for the web by Vite.
The javascript dependencies are handled by `npm` and can be found in the
[package.json](package.json) file.

To add a new javascript dependency, run the command:

```sh
./do run npm install <module_name> --save
```

#### [AlpineJS](https://alpinejs.dev/)

AlpineJS is used to add basic interactivity into the site and its components
without the need to include a large front-end framework.

#### [Turbo](https://turbo.hotwired.dev/)

Turbo is used improve page transitions and add SPA-like functionality without
the overhead of a full frontend framework.

#### [Vue 3](https://vuejs.org/)

Vue 3 is used to integrate more complex functionality into the site.

Because of the overhead and complexity of frontend frameworks like Vue, it is
used sparingly.

### Styling

This project uses the TailwindCSS CSS framework, compiled by Vite. We embrace the
Tailwind approach by avoiding the use of semantic classes in `.css` stylesheets,
and instead using Tailwind utility classes in [components].

The [tailwindcss-unimportant] plugin is used to allow component classes to be
easily overridden.

#### Icons

The [icons] in the site are provided by Google's [material symbols] package. The
icons are stored in a single variable font file, so they are both lightweight
and customisable.

## Setup

### Prequisites

This project requires [docker] to be installed to run the local development
environment.

### First time setup

Copy the template `.env.template` to `.env`:

```shell
cp .env.template .env
```

You may need to update some of the values in the `.env` file.

Build and start the docker server:

```shell
./do up
```

Seed the database with default data:

```shell
./do rails db:seed
```

The local development server will now be available at http://127.0.0.1:3000.

You can connect to the the PostgreSQL database at 127.0.0.1:5433 using `pgsql`
and `password` as the username and password.

All emails sent by the system will be sent to Mailpit, http://127.0.0.1:8025.

### Start The Development Server

Once the first time setup has been completed, the development server can be run
with a single command:

```sh
./do up
```

## Testing and coding standards

Run the coding standards:

```shell
./do cs
```

Run the unit and integration tests:

```shell
./do test
```

Run the system tests:

```
./do test:system
```

### Visual regression testing

When run, the system test suite takes visual snapshots of the site, saved locally to `tmp/snapshots/`. The visual regression testing tools allow us to baseline a new set of snapshots, compare differences against the baseline, and perform a simulated eye-tracking analysis on the images.

After the system tests have been run once on main, save the current set of snapshots as the baseline:

```shell
./do vr:baseline
```

Once you make changes to the site and have re-run the system tests, compare the new snapshots against the baseline, results in `tmp/snapshots/diff/`:

```shell
./do vr:diff
```

Perform a simulated eye-tracking analysis for each page of the site, results in `tmp/snapshots/heatmaps/`

```shell
./do vr:heatmap
```

To run all the system tests followed by a visual regression diff, you can use the `tsv` shortcut:

```shell
./do tsv
```

### Running commands

Run a command using the `./do` script:

```shell
./do run ruby --version
```

Run a rails command (this is an alias of `./do run bin/rails`):

```shell
./do rails test
```

Run a rake command (this is an alias of `./do run bin/rake`):

```shell
./do rake standard
```

Run a Heroku CLI command:

```shell
./do heroku login
```

For more information on the commands, see the [do](do) script or run:

```shell
./do help
```

[feature tests]: test/feature
[docker-compose]: docker-compose.yml
[setup]: #setup
[RBlade]: https://github.com/mwnciau/rblade
[vite_rails]: https://vite-ruby.netlify.app/guide/rails.html
[component library]: http://127.0.0.1:3000/component-library
[entrypoint]: app/frontend/entrypoints
[application entrypoint]: app/frontend/entrypoints/application.ts
[docker]: https://www.docker.com/
[components]: app/views/components
[tailwindcss-unimportant]: https://www.npmjs.com/package/tailwindcss-unimportant
[material symbols]: https://fonts.google.com/icons
[icons]: app/views/components/icon
