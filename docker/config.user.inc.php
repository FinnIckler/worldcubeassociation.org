<?php

declare(strict_types=1);

/**
* Servers configuration
*/
$i = 0;

/**
* First server
*/
$i++;
/* Authentication type */
$cfg['Servers'][$i]['auth_type'] = 'signon';
// $cfg['Servers'][$i]['SignonScript'] = "/etc/phpmyadmin/signon-script.php";
$cfg['Servers'][$i]['SignonURL'] = "http://localhost:3000/api/v0/auth/results";
$cfg['Servers'][$i]['SignonSession'] = '_WcaOnRails_session';
/* Server parameters */
$cfg['Servers'][$i]['compress'] = false;
$cfg['Servers'][$i]['AllowNoPassword'] = true;
