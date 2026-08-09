import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { AuthenticatedCustomer } from '../../customer/interfaces/authenticated-customer.interface';
import { CustomerRepository } from '../../customer/customer.repository';
import { AuthRepository } from '../auth.repository';
import {
  AuthenticatedEmployee,
  CustomerJwtPayload,
  EmployeeJwtPayload,
  JwtPayload,
} from '../interfaces/jwt-payload.interface';
import { extractPermissions, extractRoles } from '../utils/role.util';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    configService: ConfigService,
    private readonly authRepository: AuthRepository,
    private readonly customerRepository: CustomerRepository,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.getOrThrow<string>('jwt.secret'),
    });
  }

  async validate(
    payload: JwtPayload,
  ): Promise<AuthenticatedEmployee | AuthenticatedCustomer> {
    if (payload.actorType === 'customer') {
      return this.validateCustomer(payload);
    }

    return this.validateEmployee(payload as EmployeeJwtPayload);
  }

  private async validateCustomer(
    payload: CustomerJwtPayload,
  ): Promise<AuthenticatedCustomer> {
    if (payload.tokenType === 'refresh') {
      throw new UnauthorizedException('Unauthorized');
    }

    const customer = await this.customerRepository.findById(payload.customerId);

    if (!customer || !customer.isActive) {
      throw new UnauthorizedException('Unauthorized');
    }

    return {
      actorType: 'customer',
      customerId: customer.id,
      phone: customer.phone,
    };
  }

  private async validateEmployee(
    payload: EmployeeJwtPayload,
  ): Promise<AuthenticatedEmployee> {
    const employee = await this.authRepository.findEmployeeById(
      payload.employeeId,
    );

    if (!employee) {
      throw new UnauthorizedException('Unauthorized');
    }

    const roles = extractRoles(employee.employeeRoles);
    const permissions = extractPermissions(employee.employeeRoles);

    return {
      actorType: 'employee',
      employeeId: employee.id,
      phone: employee.phone,
      roles,
      permissions,
    };
  }
}
