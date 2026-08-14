import { PrismaClient } from '@prisma/client';

const LOCKER_CONFIG = [
  { code: 'A', name: 'Laci A', boxCount: 9 },
  { code: 'B', name: 'Laci B', boxCount: 15 },
  { code: 'C', name: 'Laci C', boxCount: 15 },
] as const;

export async function seedStorageLockersAndBoxes(prisma: PrismaClient) {
  for (const locker of LOCKER_CONFIG) {
    const lockerRecord = await prisma.storageLocker.upsert({
      where: { code: locker.code },
      update: { name: locker.name, isActive: true },
      create: {
        code: locker.code,
        name: locker.name,
        isActive: true,
      },
    });

    for (let boxNumber = 1; boxNumber <= locker.boxCount; boxNumber += 1) {
      const code = `${locker.code}-${String(boxNumber).padStart(2, '0')}`;
      await prisma.storageBox.upsert({
        where: { code },
        update: {
          lockerId: lockerRecord.id,
          boxNumber,
          isActive: true,
        },
        create: {
          lockerId: lockerRecord.id,
          boxNumber,
          code,
          isActive: true,
        },
      });
    }
  }
}
