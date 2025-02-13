<a href="https://opensource.newrelic.com/oss-category/#community-project"><picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/newrelic/opensource-website/raw/main/src/images/categories/dark/Community_Project.png"><source media="(prefers-color-scheme: light)" srcset="https://github.com/newrelic/opensource-website/raw/main/src/images/categories/Community_Project.png"><img alt="New Relic Open Source community project banner." src="https://github.com/newrelic/opensource-website/raw/main/src/images/categories/Community_Project.png"></picture></a>

# Core Integrations team automation

This repository acts as a place to put actions automating tasks for the Core Integrations team.

## Deployed actions

### Reposettings

Upstream: [txqueuelen/reposettings](https://github.com/txqueuelen/reposettings)

Reposettings reads a YAML file and ensures that repositories match the specified config.

## Shared Workflows

### trigger_prerelease

Reusable workflow to pre-release. This is used by ohai repos trigger_prerelease workflow

  Usage:
  ```
  jobs:
    your_prerelease_job_name:
      uses: newrelic/k8s-agents-automation/.github/workflows/trigger_prerelease.yaml@v1
      secrets:
        bot_token: 'github token'
        slack_channel: 'slack channel for sending a message in case of failure'
        slack_token: 'slack token for sending the above message'
  ```
## Automatic releases block endpoint

This repo exposes a github page from the `gh_page` branch containing a file `automatic_release_enable` which is used as a block endpoint.
Automatic pre-releases executes a GET request to it and fails if the status response is different than 200.

The block mechanism can be manually set by manually executing the workflow [Block automatic releases](.github/workflows/block.yaml) and unset by the workflow [Unblock automatic releases](.github/workflows/unblock.yaml) from the Actions panel.

## Renovate shared config

[renovate-base.json5](./renovate-base.json5) defines a base renovate configuration to be used in all core-int repositories.

 It can be used directly like this:

```json5
{
  "extends": [
    "github>newrelic/k8s-agents-automation:renovate-base.json5"
  ]
}
```

Or include additional rules if needed:

```json5
 "extends": [
   "github>newrelic/k8s-agents-automation:renovate-base.json5"
  ],
  "packageRules": [
    // ...
  ]
```

Check [Shareable Config Presets in Renovate Docs](https://docs.renovatebot.com/config-presets/#github-actions) for further information.

### Renovate configuration resources

* Renovate logs can be check in [mend developer website](https://developer.mend.io/).

**A note about vulnerabilities**

As noted in our [security policy](../../security/policy), New Relic is committed to the privacy and security of our customers and their data. We believe that providing coordinated disclosure by security researchers and engaging with the security community are important means to achieve our security goals.

If you believe you have found a security vulnerability in this project or any of New Relic's products or websites, we welcome and greatly appreciate you reporting it to New Relic through [our bug bounty program](https://docs.newrelic.com/docs/security/security-privacy/information-security/report-security-vulnerabilities/).

If you would like to contribute to this project, review [these guidelines](./CONTRIBUTING.md).

To all contributors, we thank you!  Without your contribution, this project would not be what it is today.  We also host a community project page dedicated to [Project Name](<LINK TO https://opensource.newrelic.com/projects/... PAGE>).

## Support

New Relic hosts and moderates an online forum where customers can interact with New Relic employees as well as other customers to get help and share best practices. Like all official New Relic open source projects, there's a related [Community](https://forum.newrelic.com) topic in the New Relic Explorers Hub.

## License
[Project Name] is licensed under the [Apache 2.0](http://apache.org/licenses/LICENSE-2.0.txt) License.
>[If applicable: The [project name] also uses source code from third-party libraries. You can find full details on which libraries are used and the terms under which they are licensed in the third-party notices document.]
