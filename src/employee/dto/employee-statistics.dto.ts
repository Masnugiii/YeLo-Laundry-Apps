import { ApiProperty } from '@nestjs/swagger';

export class EmployeeStatisticsDto {
  @ApiProperty({ example: 25 })
  totalEmployees!: number;

  @ApiProperty({ example: 20 })
  activeEmployees!: number;

  @ApiProperty({ example: 3 })
  inactiveEmployees!: number;

  @ApiProperty({ example: 2 })
  managers!: number;

  @ApiProperty({ example: 5 })
  cashiers!: number;

  @ApiProperty({ example: 4 })
  operators!: number;

  @ApiProperty({ example: 3 })
  drivers!: number;

  @ApiProperty({ example: 6 })
  binatu!: number;
}
