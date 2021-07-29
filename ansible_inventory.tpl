---
all:
  hosts:
%{ for i in range(length(ip_adr)) ~}
    ${name[i]}:   
      ansible_host: ${ip_adr[i]}
%{ endfor ~}
