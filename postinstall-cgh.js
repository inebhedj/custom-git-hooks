/*
 * Custom-git-hooks postinstall helper module to the npm based repositories
 *
 * Dependecies (install in your repository before use this script):
 *
 * npm install -save-dev git-clone git-pull
 *
 * Copy this file into your repository's root folder and insert next lines into your postinstall.js
 *
 * require('./postinstall-cgh')(
 *   process.argv
 *     .map((item) => {
 *       return item.match(
 *         /^cgh:[clone|cloneonly|install|installonly|pull|pullonly]/gi
 *       )
 *         ? item.replace(/^cgh:/gi, '').toLowerCase()
 *         : false;
 *     })
 *     .filter((item) => item !== false)
 * );
 *
 * Available Custom-git-hooks related postinstall attributes after modification above:
 *
 * cgh:clone         - default: clone (or pull if exists in local) repository and install / update Custom-git-hooks (eg: node postinstall.js cgh:clone)
 * cgh:cloneonly     - only clone (if not exists in local) repository (eg: node postinstall.js cgh:cloneonly)
 * cgh:install       - install / update Custom-git-hooks (or clone before, if repository not exists in local) (eg: node postinstall.js cgh:install)
 * cgh:installonly   - only install / update Custom-git-hooks (if repository exists in local) (eg: node postinstall.js cgh:installonly)
 * cgh:pull          - pull (or clone before if not exists in local) repository and install / update Custom-git-hooks (eg: node postinstall.js cgh:pull)
 * cgh:pullonly      - only pull (if exists in local) repository (eg: node postinstall.js cgh:pullonly)
 *
 */

module.exports = (config = []) => {
  console.log('POSTINSTALL: Custom-git-hooks started...');

  const fs = require('fs');
  const path = require('path');
  const gitpull = require('git-pull');
  const gitclone = require('git-clone');
  const rootPath = path.resolve(__dirname);

  const cgh = {
    directory: `${rootPath}/custom-git-hooks/`,
    installscript: 'custom-git-hooks-install.sh',
    name: 'Custom-git-hooks',
    repository: 'https://github.com/velkeit/custom-git-hooks.git',
  };

  let startParams = {
    clone: false,
    cloneonly: false,
    install: false,
    installonly: false,
    pull: false,
    pullonly: false,
  };
  let workFlow = {
    clone: false,
    install: false,
    pull: false,
  };
  let hasStartParams = false;

  const cghCheck = () => fs.existsSync(`${cgh.directory}${cgh.installscript}`);

  const cghInit = () => {
    if (typeof config === 'object' && config instanceof Array) {
      config.forEach((name) => {
        if (
          typeof startParams[
            name.toLowerCase().trim().replace(/^cgh:/g, '')
          ] === 'boolean'
        ) {
          startParams[name.toLowerCase().trim().replace(/^cgh:/g, '')] = true;
          if (name.match(/only$/gi)) {
            startParams[
              name
                .toLowerCase()
                .trim()
                .replace(/only$/g, '')
                .replace(/^cgh:/g, '')
            ] = true;
          }
          hasStartParams = true;
        }
      });
    }
    if (!hasStartParams) {
      startParams.clone = true;
    }
    ['clone', 'pull', 'install'].forEach((cmd) => {
      if (startParams[cmd]) {
        cghMethods[cmd](startParams);
      }
    });
  };

  const cghMethods = {
    clone: (startParams) => {
      if (!workFlow.clone) {
        console.log(
          `Starting clone of ${cgh.name} from ${cgh.repository} to ${cgh.directory}...`
        );

        const cghCloneHelper = (err) => {
          if (typeof err === 'object') {
            console.log('Error in clone method:', err);
          } else if (!startParams.cloneonly) {
            workFlow.clone = true;
            cghMethods.install(startParams);
          }
        };

        if (!cghCheck()) {
          gitclone(cgh.repository, cgh.directory, cghCloneHelper);
        } else {
          console.log(
            `The ${cgh.directory} directory exists, cloning cannot be performed. Maybe you must to delete before install?`
          );

          if (!startParams.cloneonly) {
            console.log('So, trying to pull...');
            cghMethods.pull(startParams);
          }
        }
      } else {
        console.log('No more cloning...');
      }
    },
    install: (startParams) => {
      if (!workFlow.install) {
        console.log(
          `Try to run install / update script ${cgh.directory}${cgh.installscript} in ${cgh.directory}...`
        );
        if (cghCheck()) {
          require('child_process').exec(
            `cd "${cgh.directory}"; sh "${cgh.directory}${cgh.installscript}"; cd ..`,
            (error, stdout, stderr) => {
              console.log('Summary:');
              if (error) {
                console.error(`exec error: ${error}`);
                console.error(`stderr: ${stderr}`);
              }
              console.log(`stdout: ${stdout}`);
              workFlow.install = true;
            }
          );
        } else {
          console.log(
            `Not found update script ${cgh.directory}${cgh.installscript} in ${cgh.directory}...`
          );
          if (!startParams.installonly) {
            console.log('So, trying to clone...');
            cghMethods.clone(startParams);
          }
        }
      } else {
        console.log('Installation is already taken.');
      }
    },
    pull: (startParams) => {
      if (!workFlow.pull) {
        console.log(
          `Starting pull of ${cgh.name} from ${cgh.repository} in ${cgh.directory}...`
        );

        const cghPullHelper = (err, consoleOutput) => {
          if (err) {
            console.log('Error:', err, consoleOutput);
          } else {
            workFlow.pull = true;
            console.log('OK:', consoleOutput);
            if (!startParams.pullonly) {
              cghMethods.install(startParams);
            }
          }
        };

        if (cghCheck()) {
          gitpull(cgh.directory, cghPullHelper);
        } else {
          console.log(
            `The ${cgh.directory} directory does not exists, pulling cannot be performed. Maybe you must to clone before pull?`
          );

          if (!startParams.pullonly) {
            console.log('So, trying to clone...');
            cghMethods.clone(startParams);
          }
        }
      } else {
        console.log('No more pulling...');
      }
    },
  };

  cghInit();

  console.log('POSTINSTALL: Custom-git-hooks done... or something...');
};
