{ config, pkgs, ... }:

{

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "rockpro05" = {
        host = "rockpro05";
        hostname = "10.0.0.15";
        user = "hugh";
      };
      "rockpro04" = {
        host = "rockpro04";
        hostname = "10.0.0.14";
        user = "hugh";
      };
      "rockpro03" = {
        host = "rockpro03";
        hostname = "10.0.0.13";
        user = "hugh";
      };
      "rockpro02" = {
        host = "rockpro02";
        hostname = "10.0.0.12";
        user = "hugh";
      };
      "rockpro01" = {
        host = "rockpro01";
        hostname = "10.0.0.11";
        user = "hugh";
      };
      "rockpro00" = {
        host = "rockpro00";
        hostname = "10.0.0.10";
        user = "hugh";
      };
      "mirror" = {
        host = "mirror";
        hostname = "10.0.0.30";
        user = "pi";
      };
    };
  }; 
 
}
