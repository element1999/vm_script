require 'set'
require 'erb'

build_sequence="""
foundation
shared
asnkernel
alarmRmi
pdmRmi
tmplsinterface
images
data
pen
pdm
pdm_1_1
pdm_1_2
pdm_2_0
pdm_3_0
pdm_4_0
pdm_5_0
pdm_5_1
pdm_6_0
pdm_6_1
pdm_7_0
pdm_7_2
pdm_8_1
pdm_8_2
neaccessRmi
bulktransferxsd
testclientxsd
dmi
common
schemamapping
em
pojolayer
comms
networkdisplayinterface
client
cccbroker
pdmEmulator
procman
version
dbAdmin
mplstpRmi
cccserver
alarm
bulktransfer
nlstext
upgrade
maintenance
mv36sim
soesaSimRmi
soesasim
""".split
#mv38_nui_dev
#inmemorydatabase
#nsm


def get_proj_dependency_map
dependency_list="""
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
cccserver->i38  ??
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


dependency_map={};
dependency_list.each{ |line|
		tmp=line.split("->")
		if tmp.size == 2
			if dependency_map.has_key? tmp[1]
				dependency_map[tmp[1]]<<tmp[0]
			else
				dependency_map[tmp[1]]=[tmp[0]]
			end
		end
	}	 





def getImpactProj proj_dependency_map,proj_name,impact_set
	impact_set.add(proj_name)
	if proj_dependency_map[proj_name]
		proj_dependency_map[proj_name].each{ |proj|
			impact_set.add(proj)
			getImpactProj(proj_dependency_map,proj,impact_set)
		}
	end
end



def changed_file_list_by_version version
	content=`git diff HEAD "#{version}" --name-only`
	p content
	content.split
end

def changed_file_list_local 
	`git status -s |awk '{print $2}'`.split
end

def changed_proj_list_local 
	`git status -s |awk -F '/s| ' '{print $3}' |sort -u`
end


def get_change rev_file
	last_build_rev=`cat "#{rev_file}"`.chop!
	content=`git diff HEAD "#{last_build_rev}" --name-only`
	changeFileList=content.split
	changed_projects=Set.new;
	changeFileList.each{ |changeFilePath|
		changed_projects.add(changeFilePath.split('/')[2])
	}
	changed_projects
end

def get_version file
	`cat "#{rev_file}"`.chop!
end

def get_changed_nsm
	changed_proj_nsm=get_change '~/ibuild/nsm_last_rev'
	if changed_proj_nsm.
		//todo
end

def get_change_proj
	changed_proj_esa=get_change '~/ibuild/esa_last_rev'
	changed_proj_esa.delete 'nsm'
	
	last_build_rev=`cat ~/.ibuild/last_build_rev`.chop!
	content=`git diff HEAD "#{last_build_rev}" --name-only`
	changeFileList=content.split
	puts changeFileList.join "\n"

	changed_projects=Set.new;
	changeFileList.each{ |changeFilePath|
		changed_projects.add(changeFilePath.split('/')[2])
	}
	local_changed_projs=`git status -s |awk -F '/s| ' '{print $3}' |sort -u`
	p 'ssss-'+local_changed_projs
	p local_changed_projs.split
	changed_projects.union(local_changed_projs.split)
end

def nsm_file_filter filelist
	filelist.select {|file|
		file.starts_with? 'nsm'
	}
end

def get_change_main
	esa_last_build_version = get_version '~/ibuild/esa_last_rev'
	nsm_last_build_version = get_version '~/ibuild/nsm_last_rev'
	esa_changed_file_list_commited = changed_file_list_by_version esa_last_build_version
	nsm_changed_file_list_commited = changed_file_list_by_version nsm_last_build_version
	all_changed_uncommit_file_list = changed_file_list_local


end
def sort_proj  build_sequence,proj_set
	c=proj_set.sort{ |a,b|
		index_a = build_sequence.index(a) || 100
		index_b = build_sequence.index(b) || 100
		index_a <=>index_b	
}
end


changed_proj=get_change_proj
p 'changed project list'
p changed_proj
proj_dependency_map=get_proj_dependency_map

impacted_projects=Set.new
changed_proj.each { |proj|
	getImpactProj proj_dependency_map,proj,impacted_projects
}

p 'impacted project list'
p impacted_projects

build_sequence_set = Set.new build_sequence
res_set= build_sequence_set & impacted_projects
res=sort_proj(build_sequence,res_set)

has_nsm=impacted_projects.include?('nsm')
has_license=impacted_projects.include?('license')
has_em=impacted_projects.include?('em')
has_pojolayer=impacted_projects.include?('pojolayer')
has_inmemorydatabase=impacted_projects.include?('inmemorydatabase')
has_procman=impacted_projects.include?('procman')
has_cccserver=impacted_projects.include?('cccserver')

if has_cccserver
	`touch runcccserver`
else
	`rm runcccserver`
end
# output_res = output_result(res)
# p output_res

template=ERB.new File.open('ibuild_t.xml').read

target=File.new 'ibuild_gen.xml','w'
target.puts template.result
