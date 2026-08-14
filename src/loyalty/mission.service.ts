import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { MissionType, RewardPointSource } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { RewardService } from './reward.service';

export interface MissionListItem {
  id: string;
  code: string;
  type: MissionType;
  title: string;
  description: string | null;
  rewardPoints: number;
  status: 'available' | 'completed';
  ctaLabel: string;
  progressLabel: string | null;
}

@Injectable()
export class MissionService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly rewardService: RewardService,
  ) {}

  async listForCustomer(customerId: string): Promise<MissionListItem[]> {
    const [missions, claims] = await Promise.all([
      this.prisma.loyaltyMission.findMany({
        where: { deletedAt: null, isActive: true },
        orderBy: [{ sortOrder: 'asc' }, { title: 'asc' }],
      }),
      this.prisma.customerMissionClaim.findMany({
        where: { customerId },
        select: { missionId: true },
      }),
    ]);

    const claimedIds = new Set(claims.map((claim) => claim.missionId));

    return missions.map((mission) => {
      const completed = claimedIds.has(mission.id);
      return {
        id: mission.id,
        code: mission.code,
        type: mission.type,
        title: mission.title,
        description: mission.description,
        rewardPoints: mission.rewardPoints,
        status: completed ? 'completed' : 'available',
        ctaLabel: this.ctaLabel(mission.type, completed),
        progressLabel: this.progressLabel(mission.type, completed),
      };
    });
  }

  async claimMission(customerId: string, missionId: string) {
    const mission = await this.prisma.loyaltyMission.findFirst({
      where: { id: missionId, deletedAt: null, isActive: true },
    });

    if (!mission) {
      throw new NotFoundException('Mission not found');
    }

    const existing = await this.prisma.customerMissionClaim.findUnique({
      where: {
        customerId_missionId: { customerId, missionId },
      },
    });

    if (existing) {
      throw new ConflictException('Mission already claimed');
    }

    return this.prisma.$transaction(async (tx) => {
      const claim = await tx.customerMissionClaim.create({
        data: { customerId, missionId },
      });

      const reward = await this.rewardService.addPoints({
        customerId,
        point: mission.rewardPoints,
        source: RewardPointSource.mission,
        description: `Mission: ${mission.title}`,
        referenceType: 'MISSION',
        referenceId: mission.id,
      });

      return {
        claim,
        reward,
        mission,
      };
    });
  }

  async seedDefaultMissions() {
    const defaults = [
      {
        code: 'QUIZ_KENALI_YELO',
        type: MissionType.quiz,
        title: 'Kenali Yelo Laundry',
        description: 'Selesaikan 3 pertanyaan',
        rewardPoints: 50,
        sortOrder: 1,
      },
      {
        code: 'LINK_ACCOUNT',
        type: MissionType.link_account,
        title: 'Tautkan akun',
        description: 'Hubungkan akunmu dan dapatkan poin',
        rewardPoints: 100,
        sortOrder: 2,
      },
      {
        code: 'REFER_FRIEND',
        type: MissionType.refer_friend,
        title: 'Ajak Teman',
        description: 'Temanmu melakukan top up minimal Rp10.000',
        rewardPoints: 1,
        sortOrder: 3,
      },
    ];

    for (const mission of defaults) {
      await this.prisma.loyaltyMission.upsert({
        where: { code: mission.code },
        create: mission,
        update: {},
      });
    }
  }

  private ctaLabel(type: MissionType, completed: boolean): string {
    if (completed) return 'Selesai';
    return switchMissionType(type, {
      quiz: 'Mulai',
      link_account: 'Tautkan',
      refer_friend: 'Ajak Teman',
    });
  }

  private progressLabel(type: MissionType, completed: boolean): string | null {
    if (completed) return null;
    if (type === MissionType.quiz) return '0/3 pertanyaan';
    return null;
  }
}

function switchMissionType<T>(
  type: MissionType,
  map: Record<MissionType, T>,
): T {
  return map[type];
}
