#!/usr/bin/perl
# Cluster Health Monitor for 1Panel Kubernetes local
# Usage: perl monitor_cluster.pl

use strict;
use warnings;
use Time::HiRes qw(gettimeofday tv_interval);

my $start_time = [gettimeofday];
my $cluster_name = "Local-K3s-Dev";

print "--- Monitoring Report for $cluster_name ---\n";

# Check if kubectl is available
my $kubectl_check = `which kubectl`;
if (!$kubectl_check) {
    die "Error: kubectl is not installed in your PATH.\n";
}

# Subroutine to check pod status
sub check_pods {
    print "[1/2] Checking Pod status...\n";
    my $output = `kubectl get pods --no-headers 2>&1`;
    
    if ($output =~ /Error/ || $output =~ /Forbidden/) {
        print "Error: Cannot access cluster API. Check Kubeconfig permissions.\n";
        return 0;
    }

    my @pods = split("\n", $output);
    my $running = 0;
    my $failed = 0;

    foreach my $line (@pods) {
        my ($name, $status) = split(/\s+/, $line);
        if ($status eq 'Running' || $status eq 'Completed') {
            $running++;
        } else {
            $failed++;
            print "  ! Pod $name is in state: $status\n";
        }
    }

    print "  > Healthy pods: $running\n";
    print "  > Unhealthy pods: $failed\n";
    return 1;
}

# Subroutine to check node resources
sub check_node_resources {
    print "[2/2] Checking Node resources...\n";
    my $node_info = `kubectl top nodes 2>/dev/mm 2>&1`;
    
    if ($node_info =~ /error/ || $node_info =~ /not found/) {
        print "  ! Metrics Server not detected. Install metrics-server to use 'kubectl top'.\n";
    } else {
        print "  > Node usage details:\n$node_info";
    }
}

# Execute checks
my $success = 1;
$success = 0 unless check_pods();
$success = 0 unless check_node_resources();

my $elapsed = tv_interval($start_time);
print "\n--- End of Report (Time elapsed: " . sprintf("%.2f", $elapsed) . "s) ---\n";

exit(0 unless $success);