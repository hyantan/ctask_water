#include "StdInc.h"
#include "TaskComplexInWater.h"
#include "TaskSimpleSwim.h"
#include "TaskSimpleClimb.h"
#include "TaskComplexDie.h"
#include "TaskSimpleGoToPoint.h"
#include "TaskSimpleRunAnim.h"
#include <iostream>
#include <cstdint>

class CTaskComplex {
public:
    virtual ~CTaskComplex() = default; 
    CTaskComplex* m_pParentTask;    
    CTask* m_pSubTask;            

    virtual void MakeAbortable(CPed* ped, int abortPriority, CEvent const* event) = 0;
    virtual CTask* GetSubTask() = 0;
    virtual void SetSubTask(CTask* subTask) = 0;
    CTaskComplex() : m_pParentTask(nullptr), m_pSubTask(nullptr) {}
};

struct CTask *__thiscall CTaskComplexInWater::CreateNextSubTask(CTaskComplex *this, struct CPed *ped) {
    CTask *m_pSubTask; 
    CMatrixLink *m_matrix; 
    CSimpleTransform *p_m_pos; 
    CTaskSimpleClimb *v7; 
    char peda; 

    if (this->m_pSubTask->GetTaskType(this->m_pSubTask) != TASK_SIMPLE_SWIM)
        return 0;

    m_pSubTask = this->m_pSubTask;

    if (!m_pSubTask[7])
        return 0;

    ped->m_nPedFlags |= 0x200u;
    m_matrix = ped->m_matrix;
    peda = 1;

    if (m_matrix)
        p_m_pos = (CSimpleTransform *)&m_matrix->m_pos;
    else
        p_m_pos = &ped->m_placement;
    
    if ( *(float *)&m_pSubTask[8].m_pParentTask - p_m_pos->m_vPosn.z < CTaskSimpleClimb::ms_fMinForStretchGrab )
        peda = 2;
    
    CTaskSimpleClimb* v7 = new CTaskSimpleClimb();
    
    if (v7)
        return CTaskSimpleClimb::CTaskSimpleClimb(v7,(CEntity *)m_pSubTask[7],(CVector *)&m_pSubTask[7].m_pParentTask,*(float *)&m_pSubTask[9],(char)m_pSubTask[9].m_pParentTask,peda,0);
    else
        return 0;
}

struct CTask *__thiscall CTaskComplexInWater::CreateFirstSubTask(struct CTaskComplexInWater *this, struct CPed *ped) {
    CTask *v2;
    struct CTask *result;
    CPedGroup *PedsGroup;
    CPedGroupMembership *p_m_groupMembership;
    CTaskSimpleSwim *v6;
    CPed *Leader;
    CTaskSimpleGoToPoint *p_m_pParentTask;
    CTaskSimpleSwim *v9; 
    CTaskSimpleRunAnim *v10; 
    CTaskSimpleSwim *v11; 
    CVector a2; 
    int v13; 

    if (CPed::IsPlayer(ped) || CPopulation::IsSunbather(ped->m_nModelIndex)) {
        CTaskSimpleSwim* v11 = new CTaskSimpleSwim();
        v13 = 0;
        if (v11)
            return CTaskSimpleSwim::CTaskSimpleSwim(v11, 0, 0);
    }
    else if ((ped->m_nSecondPedFlags & 0x100000) != 0) {
        CTask* v2 = new CTask();
        v13 = 1;
        if (v2) {
            CTaskComplexDie::CTaskComplexDie((CTaskComplexDie *)v2,WEAPON_DROWNING,ANIM_GROUP_DEFAULT,ANIM_ID_DROWN,4.0,0.0,0,0,0,0);
            return result;
        }
    }
    else {
        PedsGroup = CPedGroups::GetPedsGroup(ped);
        if (PedsGroup && (p_m_groupMembership = &PedsGroup->m_groupMembership, CPedGroupMembership::GetLeader(&PedsGroup->m_groupMembership)) && CPedGroupMembership::GetLeader(p_m_groupMembership)->m_pPlayerData) {
            CTaskSimpleSwim* v6 = new CTaskSimpleSwim();
            v13 = 2;
            if (v6) {
                Leader = CPedGroupMembership::GetLeader(p_m_groupMembership);
                return CTaskSimpleSwim::CTaskSimpleSwim(v6, 0, Leader);
            }
        }
        else if (ped->m_nCreatedBy == PED_MISSION && CPedIntelligence::FindTaskByType(ped->m_pIntelligence, TASK_SIMPLE_GO_TO_POINT)) {
            p_m_pParentTask = (CTaskSimpleGoToPoint *)&CPedIntelligence::FindTaskByType(ped->m_pIntelligence,TASK_SIMPLE_GO_TO_POINT)[1].m_pParentTask; 
            a2.x = reinterpret_cast<uintptr_t>(p_m_pParentTask);  
            a2.y = reinterpret_cast<uintptr_t>(p_m_pParentTask->m_pParentTask);  
            a2.z = static_cast<uintptr_t>(p_m_pParentTask->m_moveState); 
            CTaskSimpleSwim* v9 = new CTaskSimpleSwim();
            v13 = 3;
        if (v9)
            return CTaskSimpleSwim::CTaskSimpleSwim(v9, &a2, 0);
        }
        else {
            CTaskSimpleSwim* v10 = new CTaskSimpleSwim();
            v13 = 4;
            if (v10)
                return CTaskSimpleRunAnim::CTaskSimpleRunAnim(v10, ANIM_GROUP_DEFAULT, ANIM_ID_SWIM_TREAD, 8.0, 0);
        }
    }
    return 0;
}

struct CTask *__thiscall CTaskComplexInWater::ControlSubTask(CTaskComplex *this, struct CPed *ped) {
    return this->m_pSubTask;
}

struct CTask *__thiscall CTaskComplexInWater::Clone(struct CTaskComplexInWater *this) {
    CTask *v1; 
    struct CTask *result; 
    
    CTask* v1 = new CTask();
    result = 0;
    if (v1) {
        CTaskComplex::CTaskComplex((CTaskComplex *)v1);
        return v1;
    }
    return result;
}

struct CTaskComplexInWater *__thiscall CTaskComplexInWater::~CTaskComplexInWater(struct CTaskComplexInWater *this, unsigned __int8 deletingFlags) {
    CTaskComplexInWater::~CTaskComplexInWater(this);
    if ((deletingFlags & 1) != 0)
        delete this;
    return this;
}

void CTaskComplexInWater::InjectHooks() {
    RH_ScopedVirtualClass(CTaskComplexInWater, 0x86e4ec, 11);
    RH_ScopedCategory("Tasks/TaskTypes");

    RH_ScopedInstall(Constructor, 0x6350D0);
    RH_ScopedInstall(Destructor, 0x635100);

    RH_ScopedVMTInstall(Clone, 0x6370B0);
    RH_ScopedVMTInstall(GetTaskType, 0x6350F0);
    RH_ScopedVMTInstall(CreateNextSubTask, 0x635110);
    RH_ScopedVMTInstall(CreateFirstSubTask, 0x635200);
    RH_ScopedVMTInstall(ControlSubTask, 0x635420);
}

CTaskComplexInWater *__thiscall CTaskComplexInWater::CTaskComplexInWater(CTaskComplexInWater *this) {
    CTaskComplex::CTaskComplex((CTaskComplex *)this);
    return this;
}

int __thiscall CTaskComplexInWater::GetTaskType(struct CTaskComplexInWater *this) {
    return 268;
}

CTask* CTaskComplexInWater::CreateNextSubTask(CPed* ped) {
    if (const auto swim = CTask::DynCast<CTaskSimpleSwim>(m_pSubTask); swim && swim->m_pEntity) {
        ped->bIsInTheAir = true;
        return new CTaskSimpleClimb{
            swim->m_pEntity,
            swim->m_pClimbPos,
            swim->m_fAngle,
            swim->m_nSurfaceType,
            (swim->m_pClimbPos.z - ped->GetPosition().z < CTaskSimpleClimb::ms_fMinForStretchGrab)
                ? eClimbHeights::CLIMB_PULLUP
                : eClimbHeights::CLIMB_GRAB,
            false
        };
    }
    return nullptr;
}

CTask* CTaskComplexInWater::CreateFirstSubTask(CPed* ped) {
    if (ped->IsPlayer() || CPopulation::IsSunbather(ped)) {
        return new CTaskSimpleSwim{ nullptr, nullptr };
    }

    if (!ped->bDrownsInWater) {
        return new CTaskComplexDie{
            WEAPON_DROWNING,
            ANIM_GROUP_DEFAULT,
            ANIM_ID_DROWN,
        };
    }

    if (const auto pedsGrp = ped->GetGroup()) {
        if (const auto leader = pedsGrp->GetMembership().GetLeader()) {
            assert(!!leader->m_pPlayerData == leader->IsPlayer()); // Make sure this way is the same as the old
            if (leader->IsPlayer()) {
                return new CTaskSimpleSwim{ nullptr, leader };
            }
        }
    }

    if (ped->IsCreatedByMission()) {
        if (const auto goTo = ped->GetTaskManager().Find<CTaskSimpleGoToPoint>()) {
            return new CTaskSimpleSwim{ &goTo->m_vecTargetPoint, nullptr };
        }
    }

    return new CTaskSimpleRunAnim{ANIM_GROUP_DEFAULT, ANIM_ID_SWIM_TREAD, 8.f};
}
