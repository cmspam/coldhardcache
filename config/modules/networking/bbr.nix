# Use BBR as the default TCP congestion control, with fq queuing.
{ ... }:

{
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
  };
}
