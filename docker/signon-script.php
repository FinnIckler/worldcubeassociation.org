<?php
/**
 * Single signon for phpMyAdmin
 *
 * This is just example how to use script based single signon with
 * phpMyAdmin, it is not intended to be perfect code and look, only
 * shows how you can integrate this functionality in your application.
 */

declare(strict_types=1);


/**
 * This function returns username and password.
 *
 * It can optionally use configured username as parameter.
 *
 * @param string $user User name
 *
 * @return array
 */
function get_login_credentials($user)
{
    $url = 'http://wca_on_rails:3000/api/v0/auth/results';

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $result = curl_exec($ch);
    curl_close($ch);

    $data = json_decode($result, true);

    if ($data['status'] == 'ok') {
        // Authentication succeeded, return login credentials
        $auth = ['root',''];
        return $auth;
    } else {
        // Authentication failed, return empty credentials
        return [
            '',
            ''
        ];
    }
}

