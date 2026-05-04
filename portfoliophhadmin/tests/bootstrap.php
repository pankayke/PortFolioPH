<?php

$testAppKey = 'base64:jPhaONrQt/qVn1E8wBBEBYNZjsZ9lmGUfKlW8ozLDko=';

$_ENV['APP_ENV'] = $_ENV['APP_ENV'] ?? 'testing';
$_SERVER['APP_ENV'] = $_SERVER['APP_ENV'] ?? 'testing';
putenv('APP_ENV='.($_ENV['APP_ENV'] ?? 'testing'));

$_ENV['APP_KEY'] = $testAppKey;
$_SERVER['APP_KEY'] = $testAppKey;
putenv('APP_KEY='.$testAppKey);

require __DIR__.'/../vendor/autoload.php';
