#!/usr/bin/env php
<?php
/**
 * @file
 * This script enables and disable Backdrop modules from command line.
 *
 *
 *  Enable or Disable Backdrop module from the shell.
 *
 *  Usage:        ./console.sh [OPTIONS] <modulename>
 *  Example:      ./console.sh --root="/var/www/html" --enable pathauto
 *  Example:      ./console.sh --root="/var/www/html" --disable pathauto
 *
 *  All arguments are long options.
 *
 * @code
 *  --help      Print this page.
 *
 *  --list      Display all available modules.
 *
 *  --root      Root folder for backdrop code.
 *
 *  --enable    Enable module.
 *
 *  --disable   Disable module.
 *
 * <module1>[ <module2>[ <module3> ...]]
 *
 *             One or more modules to process. Names may
 *             be separated by spaces or commas.
 * @endcode
 *
 *  To run this script you will normally invoke it from the root directory of your
 *  Backdrop installation as the webserver user (differs per configuration),
 *  or provide --root option to directory with Backdrop website.
 *
 *  @code
 *    sudo -u [wwwrun|www-data|etc] console.sh --enable path
 *    sudo -u [wwwrun|www-data|etc] console.sh --root="/var/www/html" --disable path
 *  @endcode
 */

define('CONSOLE_COLOR_SUCCESS', 32);
define('CONSOLE_COLOR_ERROR', 31);

// Set defaults and get overrides.
list($args, $count) = console_parse_args();

if ($args['help'] || $count == 0) {
  console_help();
  exit(0);
}

// Init 
console_init();

// Check if Backdrop is installed.
backdrop_bootstrap(BACKDROP_BOOTSTRAP_CONFIGURATION);
if (!backdrop_bootstrap_is_installed()) {
  echo "Backdrop must be installed before running tests.\n";
  exit(1);
}

// Bootstrap to perform initial validation or other operations.
backdrop_bootstrap(BACKDROP_BOOTSTRAP_FULL);

if ($args['list']) {
  console_list_modules();
  exit(0);
}

if($args['enable']) {
  if(empty($args['module_names'])) {
    console_print_error("Please provide module(s) names to install");
    exit(1);
  }
  if(module_enable($args['module_names'], TRUE)) {
    console_print("Enable modules " . implode(" ", $args['module_names']) . " success" , 'success');
  }
  else{
    console_print("Enable modules " . implode(" ", $args['module_names']) . " failed", 'failed');
  }
}

if($args['disable']) {
  if(empty($args['module_names'])) {
    console_print_error("Please provide module(s) names to install");
    exit(1);
  }
  module_disable($args['module_names'], TRUE);
  console_print("Disable modules " . implode(" ", $args['module_names']) . " success", 'success');
}

/**
 * Print help text.
 */
function console_help() {
  global $args;

  echo <<<EOF

Enable or Disable Backdrop module from the shell.

Usage:        {$args['script']} [OPTIONS] <modulename>
Example:      {$args['script']} --root="/var/www/html" --enable pathauto
Example:      {$args['script']} --root="/var/www/html" --disable pathauto

All arguments are long options.

  --help      Print this page.

  --list      Display all available modules.

  --root      Root folder for backdrop code.

  --enable    Enable module.

  --disable   Disable module.

  <module1>[ <module2>[ <module3> ...]]

              One or more modules to process. Names may
              be separated by spaces or commas.

To run this script you will normally invoke it from the root directory of your
Backdrop installation as the webserver user (differs per configuration),
or provide --root option to directory with Backdrop website.

sudo -u [wwwrun|www-data|etc] console.sh --enable path
sudo -u [wwwrun|www-data|etc] console.sh --root="/var/www/html" --disable path pathauto

\n
EOF;
}


/**
 * Parse execution argument and ensure that all are valid.
 *
 * @return The list of arguments.
 */
function console_parse_args() {
  // Set default values.
  $args = array(
    'script' => '',
    'help' => FALSE,
    'list' => FALSE,
    'enable' => FALSE,
    'disable' => FALSE,
    'root' => '',
    'module_names' => array(),
  );

  // Override with set values.
  $args['script'] = basename(array_shift($_SERVER['argv']));

  $count = 0;
  while ($arg = array_shift($_SERVER['argv'])) {
    // Separate option values using "=".
    $arg_value = NULL;
    if (strpos($arg, '=') !== FALSE) {
      list($arg, $arg_value) = explode('=', $arg);
    }
    // Convert each option into a ordered set of arguments.
    if (preg_match('/--(\S+)/', $arg, $matches)) {
      $arg_name = $matches[1];
      // Argument found.
      if (array_key_exists($arg_name, $args)) {
        // Argument found in list.
        // Convert incoming boolean flags based on the default values.
        if (is_bool($args[$arg_name])) {
          $args[$arg_name] = TRUE;
        }
        // If using = assignment, use the value.
        elseif (!is_null($arg_value)) {
          $args[$arg_name] = $arg_value;
        }
        // Otherwise, a space was used for assignment, pull the next argument.
        else {
          $args[$arg_name] = array_shift($_SERVER['argv']);
        }
        $count++;
      }
      else {
        // Argument not found in list.
        console_print_error("Unknown argument '$arg'.");
        exit(1);
      }
    }
    else {
      // Values found without an argument should be test names.
      $args['module_names'] += array_merge($args['module_names'], explode(',', $arg));
      $count++;
    }
    
    // Validate the root argument.
    if (!$args['root']) {
      $args['root'] = getcwd();
    }

    $bootstrap = $args['root'] . '/core/includes/bootstrap.inc';
    if(!is_file($bootstrap)){
      console_print_error("--root must be pointed to backdrop root folder.");
      exit(1);
    }
  }

  return array($args, $count);
}

/**
 * Initialize script variables and perform general setup requirements.
 */
function console_init() {
  global $args;

  $host = 'localhost';
  $path = '';

  $_SERVER['HTTP_HOST'] = $host;
  $_SERVER['REMOTE_ADDR'] = '127.0.0.1';
  $_SERVER['SERVER_ADDR'] = '127.0.0.1';
  $_SERVER['SERVER_SOFTWARE'] = '';
  $_SERVER['SERVER_NAME'] = 'localhost';
  $_SERVER['REQUEST_URI'] = $path .'/';
  $_SERVER['REQUEST_METHOD'] = 'GET';
  $_SERVER['SCRIPT_NAME'] = $path .'/index.php';
  $_SERVER['PHP_SELF'] = $path .'/index.php';
  $_SERVER['HTTP_USER_AGENT'] = 'Backdrop command line';

  if (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') {
    // Ensure that any and all environment variables are changed to https://.
    foreach ($_SERVER as $key => $value) {
      $_SERVER[$key] = str_replace('http://', 'https://', $_SERVER[$key]);
    }
  }

  /**
   * Defines the root directory of the Backdrop installation.
   */
  define('BACKDROP_ROOT', $args['root']);

  // Change the directory to the Backdrop root.
  chdir(BACKDROP_ROOT);

  require_once BACKDROP_ROOT . '/core/includes/bootstrap.inc';
}

/**
 * Display list of modules.
 */
function console_list_modules() {
  $files = system_rebuild_module_data();
  foreach($files as $module) {
    if(isset($module->info['hidden']) && $module->info['hidden'] == 1) {
      continue;
    }
    echo $module->name ."\t". ($module->status ? 'enabled' : 'disabled') ."\n";
  }

}

/**
 * Print error message prefixed with "ERROR: " and displayed in fail color
 * if color output is enabled.
 *
 * @param $message The message to print.
 */
function console_print_error($message) {
  console_print("ERROR: $message\n", 'error');
}

/**
 * Print a message to the console, if color is enabled then the specified
 * color code will be used.
 *
 * @param $message The message to print.
 * @param $status One of the following:
 *   - pass
 *   - debug
 *   - exception
 *   - fail
 */
function console_print($message, $status) {
  global $args;
  if ($args['color']) {
    $color_code = console_color_code($status);
    $message = "\033[" . $color_code . "m" . $message . "\033[0m";
  }
  // For fails and exceptions, print to the error log.
  if ($status === 'fail' || $status === 'exception') {
    fwrite(STDERR, $message);
  }
  else {
    echo $message;
  }
}

/**
 * Get the color code associated with the specified status.
 *
 * @param $status The status string to get code for.
 * @return Color code.
 */
function console_color_code($status) {
  switch ($status) {
    case 'success':
      return CONSOLE_COLOR_SUCCESS;
    case 'error':
      return CONSOLE_COLOR_ERROR;
  }
  return 0; // Default formatting.
}

