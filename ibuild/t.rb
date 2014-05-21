require 'set'
$dependency_list="""
foundation
shared->foundation
asnkernel
alarmRmi
pdmRmi
tmplsinterface
images
data
pen
pdm->pen
pdm_1_1->pen
pdm_1_2->pen
pdm_2_0->pen
pdm_3_0->pen
pdm_4_0->pen
pdm_5_0->pen
pdm_5_1->pen
pdm_6_0->pen
pdm_6_1->pen
pdm_7_0->pen
pdm_7_2->pen
pdm_8_1->pen
pdm_8_2->pen
neaccessRmi->pdm
bulktransferxsd
testclientxsd
dmi
common->pdm
schemamapping->pdm
schemamapping->dmi
em->common
em->dmi
em->alarmRmi
em->pdm_1_1
em->pdm_1_2
em->pdm_2_0
em->pdm_3_0
em->pdm_4_0
em->pdm_5_0
em->pdm_5_1
em->pdm_6_0
em->pdm_6_1
em->pdm_7_0
em->pdm_7_2
em->pdm_8_1
em->pdm_8_2
pojolayer->em
pojolayer->schemamapping
pojolayer->tmplsinterface
comms->common
networkdisplayinterface
client->common
client->schemamapping
client->networkdisplayinterface
cccbroker->common
cccbroker->dmi
pdmEmulator
procman->common
procman->schemamapping
version->common
dbAdmin->procman
dbAdmin->version
mplstpRmi
cccserver->asnkernel
cccserver->i38
cccserver->pojolayer
cccserver->comms
cccserver->procman
cccserver->alarmRmi
cccserver->pdmRmi
cccserver->mplstpRmi
cccserver->neaccessRmi
alarm->alarmRmi
alarm->pdmRmi
alarm->procman
bulktransfer->cccserver
bulktransfer->bulktransferxsd
nlstext
upgrade->version
maintenance->version
maintenance->pojolayer
mv36sim->comms
soesaSimRmi->pdm
soesasim->mv36sim
soesasim->soesaSimRmi
soesasim->em
mv38_nui_dev->data
mv38_nui_dev->client
mv38_nui_dev->dmi
nsm->asnkernel
nsm->mv38_nui_dev
nsm->client
nsm->nlstext
nsm->foundation
nsm->shared
nsm->cccserver
inmemorydatabase->pojolayer
license->nsm
""".split();

$res =Hash.new()
def get_proj_dep 
   $dependency_list.each{ |line|
    item=line.split('->')
    if $res.include? item[0]
        $res[item[0]].add item[1] if item[1]
    else
        $res[item[0]]=Set.new
        $res[item[0]].add item[1] if item[1]
    end

    if !$res.include? item[1]
        $res[item[1]]=Set.new
    end
}
end
get_proj_dep
z=0
w=0
$res.each{ |x,y|
    # p y if x == 'pen'
    if y.size == 0
        p x
        # p y
        z=z+1
    else
        w=w+1
    end
}
p z,w

