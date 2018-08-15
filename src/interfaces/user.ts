export interface IUser {
  id: number
  name: string
  email: string
  privileges: Privileges
}

export interface IUserInternal {
  id: number
  name: string
  email: string
  password: string
  privileges: Privileges
}

export interface ILoginCredentials {
  email: string
  password: string
}

export interface IUserCreateParams {
  name: string
  email: string
  password: string
  privileges: Privileges
}

export type Privileges = 'ADMIN' | 'USER'
