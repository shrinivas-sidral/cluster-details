#!/bin/bash
export cluster_details="cluster_details.log"

#for csv checks
echo "--------------------------- Cluster Details --------------------------" | tee $cluster_details

odf_op_version(){
    echo "Checking for ODF oprator version...";echo;
    echo "$ oc describe csv $(oc get csv -A | awk '{print $2}' | grep odf-operator) -n openshift-storage | head -n 6" | tee -a $cluster_details;
    echo ""
    oc describe csv $(oc get csv -A | awk '{print $2}' | grep odf-operator) -n openshift-storage | head -n 6 | tee -a  $cluster_details;
    echo "-------------------------------------------------------------------" | tee -a $cluster_details
    echo "ODF oprator version :  $(oc describe csv $(oc get csv -A | awk '{print $2}' | grep odf-operator) -n openshift-storage | head -n 1 |awk '{print $NF}')"
    echo "===================================================================";echo;
}
csv_status(){
    echo "Checking for CSVs...";echo;
    all_succeeded=false 
    while [ "$all_succeeded" = false ]; do
    if oc get csv -A --no-headers | awk '{print $NF}' | grep -v "^Succeeded$" > /dev/null; then
        echo "Not all CSVs are in Succeeded state. Checking again..."
        sleep 10  
    else
        all_succeeded=true
        echo "$ oc get csv -A" | tee -a $cluster_details;
        oc get csv -A | tee -a  $cluster_details;
        echo "-------------------------------------------------------------------" | tee -a $cluster_details
        echo "All CSVs are in Succeeded state."
        echo "===================================================================";echo;
    fi
    done
}

#for openshift-local-storage namespace pods status check 
lv_pods_status(){
    echo "Checking for openshift-local-storage namespace Pods...";echo;
    all_succeeded=false  
    while [ "$all_succeeded" = false ]; do
    if  oc get pods -n openshift-local-storage --no-headers | awk '{ print $3 }' | grep -v "^Running$"  > /dev/null; then
        echo "Not all pods are in Running state. Checking again..."
        sleep 10  
    else
        all_succeeded=true
        echo "$ oc get pods -n openshift-local-storage" | tee -a $cluster_details;
        oc get pods -n openshift-local-storage | tee -a  $cluster_details;
        echo "-------------------------------------------------------------------" | tee -a $cluster_details
        echo "All openshift-local-storage namespace Pods are in Running state."
        echo "===================================================================";echo;
    fi
    done
}

#for openshift-storage namespace pods status check 
pods_status(){
    echo "Checking for openshift-storage namespace Pods...";echo;
    all_succeeded=false  
    while [ "$all_succeeded" = false ]; do

    if  oc get pods -n openshift-storage --no-headers | awk '{ print $3 }' | grep  -vE "^(Running|Completed)$" > /dev/null; then
        echo "Not all pods are in Running state. Checking again..."
        sleep 5  
    else
        all_succeeded=true
        echo "$ oc get pods -n openshift-storage" | tee -a $cluster_details;
        oc get pods -n openshift-storage | tee -a  $cluster_details;
        echo "-------------------------------------------------------------------" | tee -a $cluster_details
        echo "All openshift-storage namespace Pods are in Running state."
        echo "===================================================================";echo;
    fi
    done
}

#for pv status check
pv_status(){
    echo "Checking for PVs...";echo;
    echo "$ oc get pv -n openshift-storage" | tee -a $cluster_details;
    oc get pv -n openshift-storage  | tee -a  $cluster_details;
    echo "-------------------------------------------------------------------" | tee -a $cluster_details
    echo "All PVs are attached.."
    echo "===================================================================";echo;
    
}

#for pvc status check
pvc_status(){
    echo "Checking for PVCs...";echo;
    echo "$ oc get pvc -n openshift-storage" | tee -a $cluster_details;
    oc get pvc -n openshift-storage  | tee -a  $cluster_details;
    echo "-------------------------------------------------------------------" | tee -a $cluster_details
    echo "All PVCs are attached.."
    echo "===================================================================";echo;
}
#for sc status check
sc_status(){
    echo "Checking for storageclass...";echo;
    echo "$ oc get sc -n openshift-storage" | tee -a $cluster_details;
    oc get sc -n openshift-storage | tee -a  $cluster_details;
    echo "-------------------------------------------------------------------" | tee -a $cluster_details
    echo "StorageClass ok.."
    echo "===================================================================";echo;
}

#for Storagecluster status check
storagecluster_status(){
    echo "Checking for StorageCluster status...";echo;
    all_succeeded=false  
    while [ "$all_succeeded" = false ]; do

    if  oc get storagecluster -n openshift-storage --no-headers | awk '{ print $3 }' | grep -v "^Ready$" > /dev/null; then
        echo "StorageCluster in Progressing state. Checking again..."
        sleep 30  
    else
        all_succeeded=true
        echo "$ oc get storagecluster -n openshift-storage" | tee -a $cluster_details;
        oc get storagecluster -n openshift-storage | tee -a  $cluster_details;
        echo "-------------------------------------------------------------------" | tee -a $cluster_details
        echo "StorageCluster status is Ready."
        echo "===================================================================";echo;
    fi
    done
}

cephcluster_status(){
    all_succeeded=false
    echo "Checking for Ceph Health...";echo;
    while [ "$all_succeeded" = false ]; do

    str=$(oc -n openshift-storage rsh `oc get pods -n openshift-storage | grep rook-ceph-tools |  awk '{print $1}'` ceph health | tr -d '[:space:]')
    if [ $str == "HEALTH_OK" ]; then
        all_succeeded=true
        echo "$ oc get cephcluster -n openshift-storage" | tee -a $cluster_details;
        oc get cephcluster -n openshift-storage | tee -a  $cluster_details;
        echo "-------------------------------------------------------------------" | tee -a $cluster_details
        echo "Ceph health the is $str."
        echo "===================================================================";echo;
    else
      echo "CepheCluster health is $str. Checking again..."
      sleep 30
    fi
    done
}


ceph_version(){
    str=$(oc -n openshift-storage rsh `oc get pods -n openshift-storage | grep rook-ceph-tools |  awk '{print $1}'` ceph -v )
    echo "Checking for ceph version...";echo;
    echo "$ oc -n openshift-storage rsh `oc get pods -n openshift-storage | grep rook-ceph-tools |  awk '{print $1}'` ceph -v" | tee -a $cluster_details;
    echo ""
    oc -n openshift-storage rsh `oc get pods -n openshift-storage | grep rook-ceph-tools |  awk '{print $1}'` ceph -v  | tee -a  $cluster_details;
    echo "-------------------------------------------------------------------" | tee -a $cluster_details
    echo "$str"
    echo "===================================================================";echo;
        
}

odf_op_version
csv_status
lv_pods_status
pods_status
pv_status
pvc_status
sc_status
storagecluster_status
cephcluster_status
ceph_version
