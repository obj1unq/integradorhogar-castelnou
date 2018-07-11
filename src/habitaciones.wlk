class Familia{
	
	var property casa = null
	var property miembros = #{}
	
	method confortPromedio(){
		return self.puntosDeConfort() /  self.cantidadDeHabitantes()
	}
	
	method cantidadDeHabitantes(){
		return miembros.size()
	}
	
	method puntosDeConfort(){
		return miembros.sum({miem => casa.habitaciones().sum({habita => habita.ConfortConHabitante(miem)})})	
	}
	
	method familiaAGusto(){
		return self.confortPromedio() > 40 and self.todosAGusto()
	}
	
	method todosAGusto(){
		return miembros.all({miem => miem.seSienteAGusto(self)})
	}
	
}

class Casa{
	
	var property habitaciones = #{}
	
	method habitacionesOcupadas(){
		return habitaciones.filter({habitacion => habitacion.ocupantes().size() > 0})
	}
	method responsablesDeLaCasa(){
		return self.habitacionesOcupadas().map({habitacion => habitacion.ocupantes().max({ocupa => ocupa.edad()})}).asSet()
	}
	
}
class Persona{
	
	var property edad = null
	var property habilidadDeCocina = false	
	
	method esMenorDe4Anios(){
		return edad <= 4
	}
	method adquirirHabilidadDeCocina(){
		habilidadDeCocina = true
	}	
	method CambioHabitacion(habitacionOrigen, habitacionDestino){
		if(habitacionDestino.puedeEntrar(self)){
			self.salirHabitacion(habitacionOrigen)
			self.entrarHabitacion(habitacionDestino)
		 	return habitacionDestino
		}else{
			return habitacionOrigen
		}
	}	
	
	method salirHabitacion(habitacionOrigen){
		habitacionOrigen.ocupantes().remove(self)
	}
	method entrarHabitacion(habitacionDestino){
		habitacionDestino.ocupantes().add(self)
	}
	method puedeEntrarEnUna(familia){
		return familia.casa().habitaciones().any({habitacion => habitacion.puedeEntrar(self)})
	}	
}

class Obsesivo inherits Persona{
	
	method seSienteAGusto(familia){
		return self.puedeEntrarEnUna(familia) and familia.casa().habitacionesOcupadas().all({habita => habita.ocupantes().size() <= 2})
	}	
}
class Goloza inherits Persona{
	method seSienteAGusto(familia){
		return self.puedeEntrarEnUna(familia) and familia.miembros().any({miem => miem.habilidadDeCocina()})
	}		
}
class Sencilla inherits Persona{
	method seSienteAGusto(familia){
		return self.puedeEntrarEnUna(familia) and familia.casa().habitaciones().size() > familia.miembros().size()
	}	
}

class Habitacion{
	var property confort = 10
	var property ocupantes = #{}
	
	
	method ConfortConHabitante(unHabitante){
		return self.confort()
	}
	method puedeEntrar(unHabitante){
		return true
	}
	
}


class Banio inherits Habitacion{
	
	
	override method ConfortConHabitante(unHabitante){
		return super(unHabitante) + self.calculaConfort(unHabitante)
	}
	
	method calculaConfort(unHabitante){
		if(unHabitante.esMenorDe4Anios()){
		  return 2
		}else{
		  return 4
		}
	}
	
	override method puedeEntrar(unHabitante){
		if(self.estaVacio()){
			return true
		}else{
			return ocupantes.any({ocupa => ocupa.esMenorDe4Anios()})		
		}
	}
	
	method estaVacio(){
		return ocupantes.size() == 0
	}
	
}

class UsoGeneral inherits Habitacion{
	
}

class Dormitorio inherits Habitacion{
	
	var property duenios = #{}
	 
	override method ConfortConHabitante(unHabitante){
		return super(unHabitante) + self.calculaConfort(unHabitante)
	}
	method cantidadDeDuenios() = duenios.size()
	
	method calculaConfort(unHabitante){
	return	if(duenios.contains(unHabitante)){						 
		 return	10/ self.cantidadDeDuenios()// Al menos un duenio existe ya que cumple el if, nunca haria division por 0
		}else{
			0
		}
	}
	
	override method puedeEntrar(unHabitante){
		return if (self.esDuenio(unHabitante)){
			true
		}
		else{
			 duenios.all({duenio => ocupantes.contains(duenio) })
		 }
		 
	}
	
	method esDuenio(unHabitante){
		return duenios.contains(unHabitante)
	}

}

class Cocina inherits Habitacion{
	
	var property m2 = null
	
	override method ConfortConHabitante(unHabitante){
		return super(unHabitante) + self.calculaConfort(unHabitante)
	}
	method calculaConfort(unHabitante){
		if(unHabitante.habilidadDeCocina()){
			return m2*porcentajeDeLasCocinas.tamano()
		}else{
			return 0
		}
	}
	
	override method puedeEntrar(unHabitante){
		if (unHabitante.habilidadDeCocina()){
			return ocupantes.any({ocupa => not ocupa.habilidadDeCocina()})
		}else{
			return true
		}
	}
	
}

object porcentajeDeLasCocinas{
	
	var property tamano = 0.1
	
}