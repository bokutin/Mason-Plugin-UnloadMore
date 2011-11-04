use inc::Module::Install;

name 'Mason-Plugin-UnloadMore';
all_from 'lib/Mason/Plugin/UnloadMore.pm';

requires 'Mason' => "2.13";

auto_install;
auto_set_repository;
githubmeta;

WriteAll;
