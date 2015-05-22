#!/usr/bin/env perl6

my @modules;

for dir('modules').grep(*.d) -> $path {
    my $meta-info = $path.child('META.info'.IO);
    next unless $meta-info.f;
    my $module = from-json($meta-info.slurp);
    $module<source-type> = 'local';
    $module<source-url> = '_BASEDIR_/' ~ $path.basename;
    @modules.push: $module;
}

spurt 'projects.json.bootstrap', to-json(@modules)
