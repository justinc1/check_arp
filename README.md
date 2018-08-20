# check_arp
A very simple script to check if particular IP address is used by more than one host (e.g. by more than MAC address). To be used with icinga2 or nagios.

Example configuration snippets:
```
// /etc/icinga2/zones.d/global-templates/commands.conf
// Assumes symbolic link /usr/lib64/nagios/plugins/check_arping.sh -> ./check_arping.sh
object CheckCommand "arping" {
        import "plugin-check-command"
        command = [ PluginDir + "/check_arping.sh" ]
        arguments = {
                "-H" = "$arping_host$"
                "-I" = "$arping_iface$"
                "-M" = "$arping_expected_mac$"
        }
}

// /etc/icinga2/conf.d/services.conf
apply Service "arping from clinet to 10.0.0.1" {
  check_command = "arping"
  command_endpoint = host.vars.client_endpoint
  assign where host.name == "client.example.com"
  vars.arping_host = "10.0.0.1"
  vars.arping_expected_mac = "AA:BB:CC:11:22:33"
}
```
