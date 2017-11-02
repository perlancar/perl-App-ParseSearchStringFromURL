package App::ParseSearchStringFromURL;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our %SPEC;

$SPEC{parse_search_string_from_url} = {
    v => 1.1,
    summary => 'Parse search string from URL',
    args => {
        urls => {
            'x.name.is_plural' => 1,
            'x.name.singular' => 'url',
            schema => ['array*', of=>'url*'],
            req => 1,
            pos => 0,
            greedy => 1,
            cmdline_src => 'stdin_or_args',
            stream => 1,
        },
        detail => {
            summary => 'If set to true, will also output other '.
                'components aside from search string',
            schema => 'bool*',
            cmdline_aliases => {l=>{}},
        },
        module => {
            schema => ['str*', in=>[
                'URI::ParseSearchString',
                'URI::ParseSearchString::More',
            ]],
            default => 'URI::ParseSearchString',
        },
    },
    result => {
        stream => 1,
    },
};
sub parse_search_string_from_url {
    #require Array::Iter;

    my %args = @_;

    my $urls = $args{urls};
    #$urls = Array::Iter::array_iter($urls) unless ref $urls eq 'CODE';
    my $detail = $args{detail};
    my $mod = $args{module};

    (my $mod_pm = "$mod.pm") =~ s!::!/!g;
    require $mod_pm;

    if ($mod =~ /^URI::ParseSearchString(?:::More)?$/) {
        my $uparse = $mod->new;
        return [
            200,
            "OK",
            sub {
                my $url = $urls->();
                return undef unless defined $url;
                if ($detail) {
                    return {
                        host          => $uparse->se_host($url),
                        name          => $uparse->se_name($url),
                        search_string => $uparse->se_term($url),
                    };
                } else {
                    return $uparse->se_term($url);
                }
            }];
    } else {
        return [500, "BUG: Unknown module", sub {undef}];
    }
}

1;
#ABSTRACT:

=cut
